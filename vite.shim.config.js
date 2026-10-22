import { mergeConfig } from "vite";

import base from "./vite.config.js";

// lets the build past the missing TurboModuleRegistry export, to reach the next error
export default mergeConfig(base, {
  build: { rolldownOptions: { shimMissingExports: true } },
});
