import Feed from '../../core/mixins/Feed.js';
import SearchHeader from '../classes/SearchHeader.js';
import SearchSubMenu from '../classes/SearchSubMenu.js';
import UniversalWatchCard from '../classes/UniversalWatchCard.js';
import ChipCloudChip from '../classes/ChipCloudChip.js';
import type { ApiResponse, Actions } from '../../core/index.js';
import type { ObservedArray, YTNode } from '../helpers.js';
import type { ISearchResponse } from '../types/index.js';
export default class Search extends Feed<ISearchResponse> {
    header?: SearchHeader;
    results: ObservedArray<YTNode>;
    refinements: string[];
    estimated_results: number;
    sub_menu?: SearchSubMenu;
    watch_card?: UniversalWatchCard;
    constructor(actions: Actions, data: ApiResponse | ISearchResponse, already_parsed?: boolean);
    /**
     * Applies a refinement filter to the search results.
     *
     * Use {@link Search.refinement_filters} to get a list of available refinements.
     *
     * @example
     * ```ts
     * const results = await yt.search('PilotRedSun');
     * // Narrow down to only YouTube Shorts
     * const shortsOnly = await results.applyRefinement('Shorts');
     * ```
     * @param refinementFilter - The text label of the chip or the {@link ChipCloudChip} node itself.
     */
    applyRefinement(refinementFilter: string | ChipCloudChip): Promise<Search>;
    /**
     * Returns a list of available refinement filters. Use {@link Search.applyRefinement} to apply a filter.
     */
    get refinement_filters(): string[];
    /**
     * Retrieves next batch of search results.
     */
    getContinuation(): Promise<Search>;
}
