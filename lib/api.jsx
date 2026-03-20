import axios from "axios";
import { getToken, clearTokens } from "./auth";

// ── Axios instance ─────────────────────────────────────────────────────────────

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000",
  headers: { "Content-Type": "application/json" },
});

// Attach token to every request automatically
api.interceptors.request.use((config) => {
  const token = getToken();
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

// Auto-logout on 401
api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      clearTokens();
      window.location.href = "/login";
    }
    return Promise.reject(err);
  }
);


// ── Auth ───────────────────────────────────────────────────────────────────────

export const authAPI = {
  register: (data) => api.post("/auth/register", data),
  login:    (data) => api.post("/auth/login", data),
  refresh:  (refreshToken) => api.post("/auth/refresh", { refresh_token: refreshToken }),
  logout:   () => api.post("/auth/logout"),
};


// ── Loops ──────────────────────────────────────────────────────────────────────

export const loopsAPI = {
  getAll:  ()           => api.get("/loops/"),
  getOne:  (id)         => api.get(`/loops/${id}`),
  create:  (data)       => api.post("/loops/", data),
  update:  (id, data)   => api.put(`/loops/${id}`, data),
  delete:  (id)         => api.delete(`/loops/${id}`),
};


// ── Checkins ───────────────────────────────────────────────────────────────────

export const checkinsAPI = {
  create:   (data)                     => api.post("/checkins/", data),
  getByLoop:(id, params)               => api.get(`/checkins/${id}`, { params }),
  getToday: ()                         => api.get("/checkins/today/all"),
  update:   (id, data)                 => api.put(`/checkins/${id}`, data),
  delete:   (id)                       => api.delete(`/checkins/${id}`),
};


// ── Analytics ──────────────────────────────────────────────────────────────────

export const analyticsAPI = {
  summary:          ()         => api.get("/analytics/summary"),
  streak:           (loopId)   => api.get(`/analytics/streak/${loopId}`),
  heatmap:          (loopId, year) => api.get(`/analytics/heatmap/${loopId}`, { params: { year } }),
  weekly:           (loopId)   => api.get(`/analytics/weekly/${loopId}`),
  categoryBreakdown:()         => api.get("/analytics/category-breakdown"),
  completionRate:   (days = 30)=> api.get("/analytics/completion-rate", { params: { days } }),
};


// ── Users ──────────────────────────────────────────────────────────────────────

export const usersAPI = {
  getMe:      ()     => api.get("/users/me"),
  updateMe:   (data) => api.put("/users/me", data),
  getMyStats: ()     => api.get("/users/me/stats"),
};

export default api;