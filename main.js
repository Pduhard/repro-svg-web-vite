import { createElement as h } from "react";
import { createRoot } from "react-dom/client";
import Svg, { Rect } from "react-native-svg";

createRoot(document.getElementById("root")).render(
  h(Svg, { width: 100, height: 100 }, h(Rect, { width: 50, height: 50, fill: "tomato" })),
);
