import { NativeModules } from 'react-native';

const { YamapSuggests } = NativeModules;

export type YamapSuggest = {
    title: string;
    subtitle?: string;
    uri?: string;
}
export type YamapCoords = {
    lon: string;
    lat: string;
};
export type YamapSuggestWithCoords = YamapSuggest & { coords?: YamapCoords };

type SuggestFetcher = (query: string) => Promise<Array<YamapSuggest>>;
const suggest: SuggestFetcher = query => YamapSuggests.suggest(query);

type SuggestWithCoordsFetcher = (query: string) => Promise<Array<YamapSuggestWithCoords>>;
const suggestWithCoords: SuggestWithCoordsFetcher = async query => {
    const suggests = await suggest(query);
    return suggests.map(item => ({...item, coords: getCoordsFromSuggest(item)}));
}

type SuggestResetter = () => Promise<void>;
const reset: SuggestResetter = () => YamapSuggests.reset();

type LatLonGetter = (suggest: YamapSuggest) => YamapCoords | undefined;
const getCoordsFromSuggest: LatLonGetter = suggest => {
    try {
        if (!suggest.uri) return undefined;
        const search = suggest.uri.split('?')[1];
        if (!search) return undefined;
        const coordsParam = search.split('&').find(searchParam => searchParam.startsWith('ll'));
        if (!coordsParam) return undefined;
        const coords = coordsParam.split('=')[1];
        if (!coords) return undefined;
        const lon = coords.split('%2C')[0];
        const lat = coords.split('%2C')[1];
        return { lat, lon };
    } catch (err) {
        return undefined;
    }
}

const Suggest = { 
    suggest,
    suggestWithCoords,
    reset,
    getCoordsFromSuggest
}

export default Suggest;