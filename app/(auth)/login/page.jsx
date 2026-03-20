"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import useAuthStore from "@/lib/store/useAuthStore";

export default function LoginPage() {
  const router = useRouter();
  const { login, isLoading, error, clearError } = useAuthStore();

  const [form, setForm] = useState({ email: "", password: "" });

  function handleChange(e) {
    clearError();
    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    const result = await login(form);
    if (result.success) router.push("/dashboard");
  }

  return (
    <>
      <h2 className="text-white text-xl font-semibold mb-1">Welcome back</h2>
      <p className="text-zinc-500 text-sm mb-6">Log in to your Loopify account</p>

      {error && (
        <div className="bg-red-500/10 border border-red-500/20 text-red-400 text-sm rounded-xl px-4 py-3 mb-5 animate-scale-in">
          {error}
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="text-zinc-400 text-xs uppercase tracking-wide mb-1.5 block">
            Email
          </label>
          <input
            type="email"
            name="email"
            value={form.email}
            onChange={handleChange}
            required
            placeholder="lenny@example.com"
            className="w-full glass-card text-white text-sm rounded-xl px-4 py-3 outline-none focus:border-violet-500 transition-all duration-200 placeholder:text-zinc-600 focus:shadow-lg focus:shadow-violet-500/5"
          />
        </div>

        <div>
          <label className="text-zinc-400 text-xs uppercase tracking-wide mb-1.5 block">
            Password
          </label>
          <input
            type="password"
            name="password"
            value={form.password}
            onChange={handleChange}
            required
            placeholder="••••••••"
            className="w-full glass-card text-white text-sm rounded-xl px-4 py-3 outline-none focus:border-violet-500 transition-all duration-200 placeholder:text-zinc-600 focus:shadow-lg focus:shadow-violet-500/5"
          />
        </div>

        <button
          type="submit"
          disabled={isLoading}
          className="w-full bg-gradient-to-r from-violet-600 to-purple-600 hover:from-violet-500 hover:to-purple-500 disabled:opacity-50 disabled:cursor-not-allowed text-white font-semibold text-sm rounded-xl py-3 transition-all duration-200 mt-2 shadow-lg shadow-violet-500/20 hover:shadow-xl hover:shadow-violet-500/30 active:scale-[0.98]"
        >
          {isLoading ? "Logging in..." : "Log in →"}
        </button>
      </form>

      <p className="text-zinc-500 text-sm text-center mt-6">
        Don&apos;t have an account?{" "}
        <Link href="/register" className="text-violet-400 hover:text-violet-300 transition-colors font-medium">
          Sign up
        </Link>
      </p>
    </>
  );
}