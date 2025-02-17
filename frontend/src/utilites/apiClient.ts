import { api } from "../api/client.ts";
import { publicApi } from "../api/public-client.ts";

export const setAuthToken = (token: string | null) => {
    if (token) {
        api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
        publicApi.defaults.headers.common['Authorization'] = `Bearer ${token}`;
    } else {
        delete api.defaults.headers.common['Authorization'];
        delete publicApi.defaults.headers.common['Authorization'];
    }
};
