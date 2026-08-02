import Feed from './Feed.js';
import ChipCloudChip from '../../parser/classes/ChipCloudChip.js';
import ChipView from '../../parser/classes/ChipView.js';
import ListItemView from '../../parser/classes/ListItemView.js';
import { type ObservedArray } from '../../parser/helpers.js';
import type { IParsedResponse } from '../../parser/index.js';
import type { ApiResponse, Actions } from '../index.js';
export interface FilterNodes {
    primary_filters?: ObservedArray<ChipCloudChip | ListItemView | ChipView>;
    secondary_filters?: ObservedArray<ChipView>;
}
export default class FilterableFeed<T extends IParsedResponse> extends Feed<T> {
    #private;
    constructor(actions: Actions, data: ApiResponse | T, already_parsed?: boolean);
    /**
     * Returns the InnerTube renderer nodes representing filters.
     */
    get filter_nodes(): FilterNodes;
    /**
     * Returns the available primary filters as strings.
     */
    get filters(): string[];
    /**
     * Returns the available secondary filters as strings.
     */
    get secondary_filters(): string[];
    /**
     * Applies given filter and returns a new {@link Feed} object.
     */
    getFilteredFeed(filter: string | ChipCloudChip | ChipView | ListItemView, secondaryFilter?: string | ChipView): Promise<Feed<T>>;
}
