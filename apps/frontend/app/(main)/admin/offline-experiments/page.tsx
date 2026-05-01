"use client";

import React, { useEffect, useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";

type Version = {
  id: string;
  label: string;
  scriptPath: string;
  allowOffline: boolean;
  compatible: boolean;
  description?: string;
};

export default function OfflineExperimentsAdminPage() {
  const { toast } = useToast();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [versions, setVersions] = useState<Version[]>([]);
  const [activeVersion, setActiveVersion] = useState("v2");
  const [activeScript, setActiveScript] = useState("/offline-dino/dino-game-fixed.js");
  const [suggestedVersion, setSuggestedVersion] = useState<string | null>(null);

  useEffect(() => {
    let alive = true;
    (async () => {
      try {
        const [versionsRes, configRes] = await Promise.all([
          fetch("/api/offline-experiments/script-versions", { cache: "no-store" }),
          fetch("/api/offline-experiments/config", { cache: "no-store" }),
        ]);
        const versionsJson = await versionsRes.json();
        const configJson = await configRes.json();
        if (!alive) return;
        const nextVersions: Version[] = versionsJson?.data?.versions || [];
        setVersions(nextVersions);
        setActiveVersion(configJson?.data?.activeGameVersion || "v2");
        setActiveScript(configJson?.data?.activeGameScript || "/offline-dino/dino-game-fixed.js");
      } catch (_) {
        if (!alive) return;
        toast({
          title: "加载失败",
          description: "无法获取离线实验配置",
          variant: "destructive",
        });
      } finally {
        if (alive) setLoading(false);
      }
    })();
    return () => {
      alive = false;
    };
  }, [toast]);

  useEffect(() => {
    if (typeof window === "undefined") return;
    const params = new URLSearchParams(window.location.search || "");
    setSuggestedVersion(params.get("suggestedVersion"));
  }, []);

  useEffect(() => {
    if (!suggestedVersion || versions.length === 0) return;
    const exists = versions.some((item) => item.id === suggestedVersion);
    if (!exists) {
      toast({
        title: "建议版本不可用",
        description: `建议版本 ${suggestedVersion} 不在当前可选列表中`,
        variant: "destructive",
      });
      return;
    }
    setActiveVersion(suggestedVersion);
    toast({
      title: "已应用自动建议",
      description: `建议版本 ${suggestedVersion} 已预填，可直接保存生效`,
    });
  }, [suggestedVersion, versions, toast]);

  const selectedVersion = versions.find((v) => v.id === activeVersion);

  const save = async () => {
    setSaving(true);
    try {
      const res = await fetch("/api/offline-experiments/config", {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          activeGameVersion: activeVersion,
        }),
      });
      const json = await res.json();
      if (!res.ok || !json?.ok) {
        throw new Error(json?.error || `HTTP ${res.status}`);
      }
      setActiveVersion(json.data.activeGameVersion);
      setActiveScript(json.data.activeGameScript);
      toast({
        title: "保存成功",
        description: `已切换到 ${json.data.activeGameVersion}`,
      });
    } catch (error) {
      toast({
        title: "保存失败",
        description: error instanceof Error ? error.message : "未知错误",
        variant: "destructive",
      });
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="space-y-6 p-6">
      <Card>
        <CardHeader>
          <CardTitle>离线小游戏版本配置</CardTitle>
          <CardDescription>
            使用版本 ID 选择游戏脚本，服务端会校验兼容性并映射到实际脚本路径。
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="max-w-md space-y-2">
            <p className="text-sm text-muted-foreground">当前版本</p>
            <Select value={activeVersion} onValueChange={setActiveVersion} disabled={loading || saving}>
              <SelectTrigger>
                <SelectValue placeholder="选择版本" />
              </SelectTrigger>
              <SelectContent>
                {versions.map((v) => (
                  <SelectItem key={v.id} value={v.id} disabled={!v.compatible}>
                    {v.id} - {v.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {selectedVersion && (
            <div className="rounded-md border bg-muted/40 p-3 text-sm">
              <p>脚本路径：<span className="font-mono">{selectedVersion.scriptPath}</span></p>
              <p>离线可用：{selectedVersion.allowOffline ? "是" : "否（需联网预热缓存）"}</p>
              <p>兼容状态：{selectedVersion.compatible ? "兼容" : "不兼容"}</p>
              {selectedVersion.description && <p className="text-muted-foreground">{selectedVersion.description}</p>}
            </div>
          )}

          <div className="rounded-md border bg-background p-3 text-sm">
            <p>当前生效版本：<span className="font-mono">{activeVersion}</span></p>
            <p>当前生效脚本：<span className="font-mono">{activeScript}</span></p>
          </div>

          <Button onClick={save} disabled={loading || saving}>
            {saving ? "保存中..." : "保存配置"}
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
