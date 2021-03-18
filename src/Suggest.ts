import { NativeModules } from "react-native";

const { YamapSuggests } = NativeModules;

export type YamapSuggest = {
  title: string;
  subtitle?: string;
  uri?: string;
};
export type YamapCoords = {
  lon: number;
  lat: number;
};
export type YamapSuggestWithCoords = YamapSuggest & Partial<YamapCoords>;

type SuggestFetcher = (query: string) => Promise<Array<YamapSuggest>>;
const suggest: SuggestFetcher = (query) => YamapSuggests.suggest(query);

type SuggestWithCoordsFetcher = (
  query: string
) => Promise<Array<YamapSuggestWithCoords>>;
const suggestWithCoords: SuggestWithCoordsFetcher = async (query) => {
  const suggests = await suggest(query);
  return suggests.map((item) => ({
    ...item,
    ...getCoordsFromSuggest(item),
  }));
};

type SuggestResetter = () => Promise<void>;
const reset: SuggestResetter = () => YamapSuggests.reset();

type LatLonGetter = (suggest: YamapSuggest) => YamapCoords | undefined;
const getCoordsFromSuggest: LatLonGetter = (suggest) => {
  const coords = suggest.uri
    ?.split("?")[1]
    ?.split("&")
    ?.find((param) => param.startsWith("ll"))
    ?.split("=")[1];
  if (!coords) return;

  const splittedCoords = coords.split("%2C");
  const lon = Number(splittedCoords[0]);
  const lat = Number(splittedCoords[1]);
  return { lat, lon };
};

const Suggest = {
  suggest,
  suggestWithCoords,
  reset,
  getCoordsFromSuggest,
};

export default Suggest;
