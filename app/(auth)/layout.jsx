export default function AuthLayout({ children }) {
  return (
    <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center px-4">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <span className="text-4xl">🔁</span>
          <h1 className="text-white text-2xl font-bold mt-2 tracking-tight">
            Loop<span className="text-violet-400">ify</span>
          </h1>
          <p className="text-zinc-500 text-sm mt-1">Build habits. Break cycles.</p>
        </div>

        {/* Card */}
        <div className="bg-[#111118] border border-white/[0.07] rounded-2xl p-8">
          {children}
        </div>
      </div>
    </div>
  );
}