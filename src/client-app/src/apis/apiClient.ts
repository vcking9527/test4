import axios from "axios";
import { Client } from "./apiModels";

const axiosInstance = axios.create({
    baseURL: `http://localhost:5001`,
    timeout: 50000,
});

const $api = new Client(undefined, axiosInstance);
export default $api;
