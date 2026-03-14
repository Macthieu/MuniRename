import Foundation
import MuniRenameCore
import OrchivisteKitContracts

public enum CanonicalRunAdapterError: Error, Sendable {
    case unsupportedAction(String)
    case missingParameter(String)
    case invalidParameter(String, String)
    case presetLoadFailed(String)
    case explicitConfirmationRequired
    case runtimeFailure(String)

    var toolError: ToolError {
        switch self {
        case .unsupportedAction(let action):
            return ToolError(
                code: "UNSUPPORTED_ACTION",
                message: "Unsupported action: \(action)",
                retryable: false
            )
        case .missingParameter(let parameter):
            return ToolError(
                code: "MISSING_PARAMETER",
                message: "Missing required parameter: \(parameter)",
                retryable: false
            )
        case .invalidParameter(let parameter, let reason):
            return ToolError(
                code: "INVALID_PARAMETER",
                message: "Invalid parameter \(parameter): \(reason)",
                retryable: false
            )
        case .presetLoadFailed(let reason):
            return ToolError(
                code: "PRESET_LOAD_FAILED",
                message: reason,
                retryable: false
            )
        case .explicitConfirmationRequired:
            return ToolError(
                code: "EXPLICIT_CONFIRMATION_REQUIRED",
                message: "Destructive apply requires confirm_apply=true and dry_run=false.",
                retryable: false
            )
        case .runtimeFailure(let reason):
            return ToolError(
                code: "RUNTIME_FAILURE",
                message: reason,
                retryable: false
            )
        }
    }
}

private enum CanonicalAction: String, Sendable {
    case preview
    case apply
    case validatePreset = "validate-preset"
}

private struct CanonicalExecutionContext: Sendable {
    let action: CanonicalAction
    let preset: RenamePreset
    let directory: URL?
    let recursive: Bool
    let includeHidden: Bool
    let dryRun: Bool
    let confirmApply: Bool
}

public enum CanonicalRunAdapter {
    public static func execute(request: ToolRequest) -> ToolResult {
        let startedAt = isoTimestamp()

        do {
            let context = try parseContext(from: request)
            let completed = try execute(request: request, context: context, startedAt: startedAt)
            return completed
        } catch let adapterError as CanonicalRunAdapterError {
            let finishedAt = isoTimestamp()
            return makeFailureResult(
                request: request,
                startedAt: startedAt,
                finishedAt: finishedAt,
                errors: [adapterError.toolError],
                summary: "Canonical request failed before completion."
            )
        } catch {
            let finishedAt = isoTimestamp()
            let toolError = CanonicalRunAdapterError.runtimeFailure(error.localizedDescription).toolError
            return makeFailureResult(
                request: request,
                startedAt: startedAt,
                finishedAt: finishedAt,
                errors: [toolError],
                summary: "Canonical request failed with an unexpected runtime error."
            )
        }
    }

    private static func execute(
        request: ToolRequest,
        context: CanonicalExecutionContext,
        startedAt: String
    ) throws -> ToolResult {
        let validationIssues = PresetValidator.validate(context.preset)

        if context.action == .validatePreset {
            let finishedAt = isoTimestamp()
            if validationIssues.isEmpty {
                return makeResult(
                    request: request,
                    status: .succeeded,
                    startedAt: startedAt,
                    finishedAt: finishedAt,
                    summary: "Preset validation succeeded.",
                    errors: [],
                    metadata: [
                        "action": .string("validate-preset"),
                        "issue_count": .number(0)
                    ]
                )
            }

            let errors = validationIssues.map { issue in
                ToolError(
                    code: "PRESET_VALIDATION_FAILED",
                    message: "[\(issue.field)] \(issue.message)",
                    details: ["field": .string(issue.field)],
                    retryable: false
                )
            }
            return makeFailureResult(
                request: request,
                startedAt: startedAt,
                finishedAt: finishedAt,
                errors: errors,
                summary: "Preset validation failed."
            )
        }

        if !validationIssues.isEmpty {
            let finishedAt = isoTimestamp()
            let errors = validationIssues.map { issue in
                ToolError(
                    code: "PRESET_VALIDATION_FAILED",
                    message: "[\(issue.field)] \(issue.message)",
                    details: ["field": .string(issue.field)],
                    retryable: false
                )
            }
            return makeFailureResult(
                request: request,
                startedAt: startedAt,
                finishedAt: finishedAt,
                errors: errors,
                summary: "Preset is invalid for execution."
            )
        }

        guard let directory = context.directory else {
            throw CanonicalRunAdapterError.missingParameter("directory_path")
        }

        var effectiveRules = context.preset.rules
        if context.recursive { effectiveRules.filters.recursive = true }
        if context.includeHidden { effectiveRules.filters.includeHidden = true }

        let items = try FileInventoryService.collectFiles(directory: directory, filters: effectiveRules.filters)
        let preview = RenameEngine.computePreview(
            items: items,
            directoryURL: directory,
            selection: [],
            previewOnlySelection: false,
            rules: effectiveRules
        )
        let warningCount = preview.byID.values.filter { !$0.status.isEmpty }.count

        if context.action == .preview || context.dryRun {
            let finishedAt = isoTimestamp()
            let status: ToolStatus = warningCount > 0 ? .needsReview : .succeeded
            let summary = context.action == .apply
                ? "Apply request executed in dry-run mode."
                : "Preview completed."
            return makeResult(
                request: request,
                status: status,
                startedAt: startedAt,
                finishedAt: finishedAt,
                summary: summary,
                errors: [],
                metadata: [
                    "action": .string(context.action.rawValue),
                    "dry_run": .bool(context.dryRun),
                    "files_analyzed": .number(Double(items.count)),
                    "warning_count": .number(Double(warningCount))
                ]
            )
        }

        guard context.confirmApply else {
            throw CanonicalRunAdapterError.explicitConfirmationRequired
        }

        let outputNames = Dictionary(uniqueKeysWithValues: preview.byID.map { ($0.key, $0.value.outputName) })
        let plan = RenameEngine.buildPlan(items: items, selection: [], outputNames: outputNames, rules: effectiveRules)
        let report = RenameEngine.apply(plan: plan, rules: effectiveRules)
        let finishedAt = isoTimestamp()

        let operationErrors = report.statuses
            .filter { !$0.value.isEmpty }
            .map { id, message in
                ToolError(
                    code: "RENAME_OPERATION_FAILED",
                    message: message,
                    details: ["item_id": .string(id.uuidString)],
                    retryable: false
                )
            }

        if report.errorCount > 0 {
            return makeFailureResult(
                request: request,
                startedAt: startedAt,
                finishedAt: finishedAt,
                errors: operationErrors.isEmpty ? [CanonicalRunAdapterError.runtimeFailure("Rename apply failed.").toolError] : operationErrors,
                summary: "Apply completed with errors."
            )
        }

        return makeResult(
            request: request,
            status: .succeeded,
            startedAt: startedAt,
            finishedAt: finishedAt,
            summary: "Apply completed successfully.",
            errors: [],
            metadata: [
                "action": .string("apply"),
                "dry_run": .bool(false),
                "files_analyzed": .number(Double(items.count)),
                "renamed_count": .number(Double(report.renamedCount)),
                "error_count": .number(Double(report.errorCount)),
                "warning_count": .number(Double(warningCount))
            ]
        )
    }

    private static func parseContext(from request: ToolRequest) throws -> CanonicalExecutionContext {
        let action = try parseAction(request.action)

        let presetPath = try requiredStringParameter("preset_path", in: request)
        let presetURL = URL(fileURLWithPath: presetPath)
        let preset: RenamePreset
        do {
            let data = try Data(contentsOf: presetURL)
            preset = try PresetCodec.decodePreset(from: data)
        } catch {
            throw CanonicalRunAdapterError.presetLoadFailed("Unable to read preset at \(presetPath): \(error.localizedDescription)")
        }

        let directoryPath = try optionalStringParameter("directory_path", in: request)
        let directoryURL = directoryPath.map { URL(fileURLWithPath: $0) }
        let recursive = try optionalBoolParameter("recursive", in: request) ?? false
        let includeHidden = try optionalBoolParameter("include_hidden", in: request) ?? false

        let dryRun: Bool
        if action == .apply {
            dryRun = try optionalBoolParameter("dry_run", in: request) ?? true
        } else {
            dryRun = true
        }

        let confirmApply = try optionalBoolParameter("confirm_apply", in: request) ?? false

        if action != .validatePreset, directoryURL == nil {
            throw CanonicalRunAdapterError.missingParameter("directory_path")
        }

        return CanonicalExecutionContext(
            action: action,
            preset: preset,
            directory: directoryURL,
            recursive: recursive,
            includeHidden: includeHidden,
            dryRun: dryRun,
            confirmApply: confirmApply
        )
    }

    private static func parseAction(_ rawValue: String) throws -> CanonicalAction {
        let normalized = rawValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "_", with: "-")

        switch normalized {
        case "preview":
            return .preview
        case "apply":
            return .apply
        case "validate-preset":
            return .validatePreset
        default:
            throw CanonicalRunAdapterError.unsupportedAction(rawValue)
        }
    }

    private static func requiredStringParameter(_ key: String, in request: ToolRequest) throws -> String {
        guard let value = try optionalStringParameter(key, in: request) else {
            throw CanonicalRunAdapterError.missingParameter(key)
        }
        return value
    }

    private static func optionalStringParameter(_ key: String, in request: ToolRequest) throws -> String? {
        guard let value = request.parameters[key] else {
            return nil
        }

        switch value {
        case .string(let stringValue):
            let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                return nil
            }
            return resolvePathFromURIOrPath(trimmed)
        default:
            throw CanonicalRunAdapterError.invalidParameter(key, "expected string")
        }
    }

    private static func optionalBoolParameter(_ key: String, in request: ToolRequest) throws -> Bool? {
        guard let value = request.parameters[key] else {
            return nil
        }

        switch value {
        case .bool(let boolValue):
            return boolValue
        default:
            throw CanonicalRunAdapterError.invalidParameter(key, "expected boolean")
        }
    }

    private static func makeResult(
        request: ToolRequest,
        status: ToolStatus,
        startedAt: String,
        finishedAt: String,
        summary: String,
        errors: [ToolError],
        metadata: [String: JSONValue]
    ) -> ToolResult {
        let progressEvents = [
            ProgressEvent(
                requestID: request.requestID,
                status: .running,
                stage: "rename_pipeline",
                percent: 10,
                message: "Execution started.",
                occurredAt: startedAt
            ),
            ProgressEvent(
                requestID: request.requestID,
                status: status,
                stage: "rename_pipeline_complete",
                percent: 100,
                message: summary,
                occurredAt: finishedAt
            )
        ]

        return ToolResult(
            requestID: request.requestID,
            tool: request.tool,
            status: status,
            startedAt: startedAt,
            finishedAt: finishedAt,
            progressEvents: progressEvents,
            outputArtifacts: [],
            errors: errors,
            summary: summary,
            metadata: metadata
        )
    }

    private static func makeFailureResult(
        request: ToolRequest,
        startedAt: String,
        finishedAt: String,
        errors: [ToolError],
        summary: String
    ) -> ToolResult {
        makeResult(
            request: request,
            status: .failed,
            startedAt: startedAt,
            finishedAt: finishedAt,
            summary: summary,
            errors: errors,
            metadata: [
                "action": .string(request.action)
            ]
        )
    }

    private static func resolvePathFromURIOrPath(_ candidate: String) -> String {
        guard let url = URL(string: candidate), url.isFileURL else {
            return candidate
        }
        return url.path
    }

    private static func isoTimestamp() -> String {
        ISO8601DateFormatter().string(from: Date())
    }
}
