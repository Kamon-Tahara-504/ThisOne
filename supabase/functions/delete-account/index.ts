// supabase/functions/delete-account/index.ts

// 型エラー抑制用（Supabase 実行環境では Deno が自動で提供される）
/* eslint-disable @typescript-eslint/no-explicit-any */
declare const Deno: any;

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// jsr インポートはローカルの tsserver では解決できないので無視させる
// @ts-ignore -- resolved only in Supabase Edge (Deno) runtime
import { createClient } from "jsr:@supabase/supabase-js@2";

// 以下はそのままでOK（corsHeaders / Deno.serve ...）
// CORS 用ヘッダー
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // 必要に応じてドメインを絞る
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  // Preflight (OPTIONS) に応答
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      status: 200,
      headers: corsHeaders,
    });
  }

  // POST 以外は拒否
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  // ボディの confirm フラグをチェック（誤操作防止）
  let body: any = {};
  try {
    body = await req.json();
  } catch {
    body = {};
  }
  const { confirm } = body;
  if (!confirm) {
    return new Response(JSON.stringify({ error: "Confirmation required" }), {
      status: 400,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  // Authorization ヘッダーからアクセストークン取得
  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.replace("Bearer", "").trim();

  if (!token) {
    return new Response(JSON.stringify({ error: "Missing access token" }), {
      status: 401,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    console.error("Missing PROJECT_URL or SERVICE_ROLE_KEY");
    return new Response(
      JSON.stringify({ error: "Server configuration error" }),
      {
        status: 500,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      },
    );
  }

  // service_role で管理者クライアントを作成
  const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });

  // アクセストークンからユーザー情報を取得
  const {
    data: { user },
    error: userError,
  } = await supabaseAdmin.auth.getUser(token);

  if (userError || !user) {
    console.error("getUser error:", userError);
    return new Response(JSON.stringify({ error: "Invalid token" }), {
      status: 401,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  const userId = user.id;

  // ユーザー関連テーブルのデータを削除
  const tables = [
    "tasks",
    "memos",
    "schedules",
    "user_profiles",
    "user_settings",
  ];

  for (const table of tables) {
    const { error } = await supabaseAdmin
      .from(table)
      .delete()
      .eq("user_id", userId);

    if (error) {
      console.error(`Error deleting from ${table}:`, error);
      // エラーがあっても続行
    }
  }

  // Auth ユーザーを削除
  const { error: deleteUserError } = await supabaseAdmin.auth.admin.deleteUser(
    userId,
  );

  if (deleteUserError) {
    console.error("Error deleting auth user:", deleteUserError);
    return new Response(
      JSON.stringify({ error: "Failed to delete auth user" }),
      {
        status: 500,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      },
    );
  }

  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });
});