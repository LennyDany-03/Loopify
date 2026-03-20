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
        <div className="bg-red-500/10 border border-red-500/20 text-red-400 text-sm rounded-lg px-4 py-3 mb-5">
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
            className="w-full bg-[#1a1a24] border border-white/[0.08] text-white text-sm rounded-lg px-4 py-3 outline-none focus:border-violet-500 transition-colors placeholder:text-zinc-600"
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
            className="w-full bg-[#1a1a24] border border-white/[0.08] text-white text-sm rounded-lg px-4 py-3 outline-none focus:border-violet-500 transition-colors placeholder:text-zinc-600"
          />
        </div>

        <button
          type="submit"
          disabled={isLoading}
          className="w-full bg-violet-600 hover:bg-violet-500 disabled:opacity-50 disabled:cursor-not-allowed text-white font-semibold text-sm rounded-lg py-3 transition-colors mt-2"
        >
          {isLoading ? "Logging in..." : "Log in →"}
        </button>
      </form>

      <p className="text-zinc-500 text-sm text-center mt-6">
        Don&apos;t have an account?{" "}
        <Link href="/register" className="text-violet-400 hover:text-violet-300 transition-colors">
          Sign up
        </Link>
      </p>
    </>
  );
}