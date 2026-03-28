"use client";

import { useRouter } from "next/navigation";
import useAuthStore from "../store/useAuthStore";

export function useAuth() {
  const router = useRouter();
  const { user, isLoggedIn, isLoading, error, login, register, logout, clearError } = useAuthStore();

  async function handleLogin(credentials) {
    const result = await login(credentials);
    if (result.success) router.push("/dashboard");
    return result;
  }

  async function handleRegister(data) {
    const result = await register(data);
    if (result.success) router.push("/dashboard");
    return result;
  }

  async function handleLogout() {
    await logout();
    router.push("/login");
  }

  return {
    user,
    isLoggedIn,
    isLoading,
    error,
    clearError,
    login:    handleLogin,
    register: handleRegister,
    logout:   handleLogout,
  };
}