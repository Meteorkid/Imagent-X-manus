import {
  DEFAULT_ACTIVE_GAME_VERSION,
  listOfflineGameScriptVersions,
  normalizeActiveGameVersion,
  resolveGameScriptPathByVersion,
  resolveVersionIdFromLegacyScriptPath,
} from "@/lib/offline-game-script";

describe("offline game script registry", () => {
  it("returns registry versions", () => {
    const versions = listOfflineGameScriptVersions();
    expect(versions.length).toBeGreaterThanOrEqual(2);
    expect(versions.some((v) => v.id === "v1")).toBe(true);
    expect(versions.some((v) => v.id === "v2")).toBe(true);
  });

  it("normalizes unknown version to default", () => {
    expect(normalizeActiveGameVersion("unknown")).toBe(DEFAULT_ACTIVE_GAME_VERSION);
  });

  it("resolves version to script path", () => {
    expect(resolveGameScriptPathByVersion("v1")).toBe("/offline-dino/dino-game.js");
    expect(resolveGameScriptPathByVersion("v2")).toBe("/offline-dino/dino-game-fixed.js");
  });

  it("maps legacy script path back to version id", () => {
    expect(resolveVersionIdFromLegacyScriptPath("/offline-dino/dino-game.js")).toBe("v1");
    expect(resolveVersionIdFromLegacyScriptPath("/offline-dino/dino-game-fixed.js")).toBe("v2");
  });
});
