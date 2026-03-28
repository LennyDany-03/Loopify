import { create } from "zustand";
import { setTokens, clearTokens, setStoredUser, getStoredUser, getToken } from "../auth";
import { authAPI, usersAPI } from "../api";

const useAuthStore = create((set, get) => ({
  user:          getStoredUser(),
  isLoggedIn:    !!getToken(),
  isLoading:     false,
  error:         null,

  // ── Register ────────────────────────────────────────────────────────────────
  register: async ({ full_name, email, password }) => {
    set({ isLoading: true, error: null });
    try {
      const res = await authAPI.register({ full_name, email, password });
      const { access_token, refresh_token, user_id } = res.data;
      setTokens(access_token, refresh_token);
      // Fetch full profile after register
      const profileRes = await usersAPI.getMe();
      setStoredUser(profileRes.data);
      set({ user: profileRes.data, isLoggedIn: true, isLoading: false });
      return { success: true };
    } catch (err) {
      const msg = err.response?.data?.detail || "Registration failed.";
      set({ error: msg, isLoading: false });
      return { success: false, error: msg };
    }
  },

  // ── Login ───────────────────────────────────────────────────────────────────
  login: async ({ email, password }) => {
    set({ isLoading: true, error: null });
    try {
      const res = await authAPI.login({ email, password });
      const { access_token, refresh_token } = res.data;
      setTokens(access_token, refresh_token);
      const profileRes = await usersAPI.getMe();
      setStoredUser(profileRes.data);
      set({ user: profileRes.data, isLoggedIn: true, isLoading: false });
      return { success: true };
    } catch (err) {
      const msg = err.response?.data?.detail || "Invalid email or password.";
      set({ error: msg, isLoading: false });
      return { success: false, error: msg };
    }
  },

  // ── Logout ──────────────────────────────────────────────────────────────────
  logout: async () => {
    try { await authAPI.logout(); } catch {}
    clearTokens();
    set({ user: null, isLoggedIn: false, error: null });
  },

  // ── Clear error ─────────────────────────────────────────────────────────────
  clearError: () => set({ error: null }),
}));

export default useAuthStore;