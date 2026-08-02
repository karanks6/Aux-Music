import { type ESTree } from 'meriyah';
export interface ExtractionConfig {
    /**
     * Predicate that determines whether the current node should be considered a match.
     */
    match: (node: ESTree.Node) => boolean | ESTree.Node;
    /**
     * When `false`, dependency resolution is not enforced and extractions are marked as ready immediately
     * when `stopWhenReady` is true.
     */
    collectDependencies?: boolean;
    /**
     * When `true`, traversal stops once the extraction is matched and all its dependencies (when `collectDependencies=true`) resolve.
     * Only useful for small functions/vars without too many dependencies. Deeper dependency trees will usually have the unresolvable
     * member expression here and there, for example:
     * ```js
     *  var Vmi = g.dX.window, Wr = Vmi?.yt?.config_ || Vmi?.ytcfg?.data_ || {};
     * ```
     *
     * Since `Vmi.ytcfg` is a dependency, it will never resolve because it comes from `g.dX.window`, which is an external object we don't have access to.
     * In cases like this, `stopWhenReady` option does nothing useful.
     */
    stopWhenReady?: boolean;
    /**
     * If `true`, dependency collection is limited to the match context node itself.
     */
    onlyProcessMatchContext?: boolean;
    /**
     * Name for easier identification of extractions.
     */
    friendlyName?: string;
}
export interface AnalyzerOptions {
    /**
     * One or more extraction configurations to look for while traversing.
     */
    extractions?: ExtractionConfig | ExtractionConfig[];
}
export interface VariableMetadata {
    name: string;
    node?: any;
    dependencies: Set<string>;
    dependents: Set<string>;
    prototypeAliases: Map<string, Set<VariableMetadata>>;
    predeclared: boolean;
}
export interface ExtractionState {
    config: ExtractionConfig;
    node?: ESTree.Node;
    metadata?: VariableMetadata;
    dependencies: Set<string>;
    dependents: Set<string>;
    matchContext?: ESTree.Node;
    ready: boolean;
}
export type ExtractionMatch = ExtractionState;
/**
 * Performs dependency-aware extraction of variables inside an IIFE.
 */
export declare class JsAnalyzer {
    private readonly source;
    private readonly programAst;
    private readonly hasExtractions;
    private readonly extractionStates;
    private readonly dependentsTracker;
    private pendingPrototypeAliasBinding;
    iifeParamName: string | null;
    readonly declaredVariables: Map<string, VariableMetadata>;
    /**
     * Creates a new instance over the provided source.
     * @param code JavaScript source to parse and inspect.
     * @param options Optional traversal settings.
     */
    constructor(code: string, options?: AnalyzerOptions);
    /**
     * Walks the AST to collect declarations and resolve initial targets.
     */
    private analyzeAst;
    /**
     * Quick check if node type requires dependency analysis
     */
    private needsDependencyAnalysis;
    /**
     * Records a match, attaches metadata, and updates readiness state.
     * @returns True when traversal can stop as a result of the match.
     */
    private onMatch;
    /**
     * Refreshes the readiness state of an extraction target based on its dependencies
     * and/or configuration.
     * @param state - State to refresh.
     */
    private refreshExtractionState;
    /**
     * Determines whether traversal should stop based on extraction states and configuration.
     */
    private shouldStopTraversal;
    /**
     * Checks if every dependency resolves to a declaration or built-in symbol.
     * @param dependencies - Dependencies to validate.
     * @param seen - Tracks recursively visited identifiers.
     */
    private areDependenciesResolved;
    /**
     * Collects free identifier dependencies reachable from the provided AST node.
     * @param rootNode - AST node to search for dependencies.
     * @param identifierName - Name of the identifier represented by `rootNode`, used for tracking dependents.
     */
    private findDependencies;
    /**
     * Returns the current set of matched extractions.
     */
    getExtractedMatches(): ExtractionMatch[];
    /**
     * Returns the raw, original source.
     */
    getSource(): string;
}
