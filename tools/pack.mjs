// Creates dist/com.monitorswitch.streamDeckPlugin (a zip of the .sdPlugin folder).
import { execFileSync } from "node:child_process";
import { mkdirSync, rmSync } from "node:fs";

mkdirSync("dist", { recursive: true });
rmSync("dist/com.monitorswitch.streamDeckPlugin", { force: true });
if (process.platform === "win32") {
  execFileSync("powershell", ["-NoProfile", "-Command",
    "Compress-Archive -Path com.monitorswitch.sdPlugin -DestinationPath dist/plugin.zip -Force; " +
    "Move-Item dist/plugin.zip dist/com.monitorswitch.streamDeckPlugin -Force"], { stdio: "inherit" });
} else {
  execFileSync("zip", ["-qr", "dist/com.monitorswitch.streamDeckPlugin", "com.monitorswitch.sdPlugin", "-x", "*/logs/*"], { stdio: "inherit" });
}
console.log("dist/com.monitorswitch.streamDeckPlugin");
