import { setupMUDNetwork } from "@latticexyz/std-client";
import {
  createWorld,
  EntityID,
  getEntitiesWithValue,
  getComponentValue,
  getComponentEntities,
} from "@latticexyz/recs";
import { Coord } from "@latticexyz/utils";
import { SystemTypes } from "contracts/types/SystemTypes";
import { SystemAbis } from "contracts/types/SystemAbis.mjs";
import {
  defineNumberComponent,
  defineCoordComponent,
  createActionSystem,
} from "@latticexyz/std-client";
import { config } from "./config";

// Canvas

const canvasSize = 0.9 * Math.min(window.innerWidth, window.innerHeight) - 20;
const canvasScale = canvasSize / 100;
const canvas = document.getElementById("canvas") as HTMLCanvasElement;
canvas.width = canvasSize;
canvas.height = canvasSize;

function canvasContext() {
  const ctx = canvas.getContext("2d");
  if (!ctx) return;
  return ctx;
}

function drawRect(ctx: CanvasRenderingContext2D | undefined, x1: number, y1: number, x2: number, y2: number) {
  if (!ctx) return;
  const rect = new Path2D();
  rect.rect(
    x1 * canvasScale,
    y1 * canvasScale,
    (x2 - x1) * canvasScale,
    (y2 - y1) * canvasScale
  );
  ctx.fillStyle = "rgba(0, 0, 0, 0.15)";
  ctx.fill(rect);
}

function drawCircle(ctx: CanvasRenderingContext2D | undefined, x: number, y: number, color: string) {
  if (!ctx) return;
  const circle = new Path2D();
  circle.arc(x * canvasScale, y * canvasScale, canvasScale, 0, 2 * Math.PI);
  ctx.fillStyle = color;
  ctx.fill(circle);
  ctx.strokeStyle = "black";
  ctx.stroke(circle);
}

function clearCanvas(ctx: CanvasRenderingContext2D | undefined) {
  if (!ctx) return;
  ctx.clearRect(0, 0, canvas.width, canvas.height);
}

function render() {
  const ctx = canvasContext();
  clearCanvas(ctx);
  for (const entity of getComponentEntities(components.Position)) {
    const position = getComponentValue(components.Position, entity);
    const color = getComponentValue(components.Color, entity);
    if (position && color) {
      drawCircle(
        ctx,
        position.x,
        position.y,
        color.value == 0 ? "#4A68FC" : "#FF8600"
      );
    }
  }
}

function clickToCoord(event: MouseEvent) {
  const rect = canvas.getBoundingClientRect();
  const x = Math.round((event.clientX - rect.left) / canvasScale);
  const y = Math.round((event.clientY - rect.top) / canvasScale);
  return { x, y };
}

// MUD

// The world contains references to all entities, all components and disposers.
const world = createWorld();

// Components contain the application state.
// If a contractId is provided, MUD syncs the state with the corresponding
// component contract (in this case `CounterComponent.sol`)
const components = {
  Color: defineNumberComponent(world, {
    metadata: { contractId: "component.Color" },
  }),
  Position: defineCoordComponent(world, {
    metadata: { contractId: "component.Position" },
  }),
};

// Components expose a stream that triggers when the component is updated.
components.Position.update$.subscribe(({ entity, value }) => {
  console.log(`Position updated ${entity}: (${value[0]?.x},${value[0]?.y})`);
});
components.Color.update$.subscribe(({ entity, value }) => {
  console.log(`Color updated ${entity}: ${value[0]?.value}`);
  render();
});

// This is where the magic happens
setupMUDNetwork<typeof components, SystemTypes>(
  config,
  world,
  components,
  SystemAbis
).then(({ startSync, systems, txReduced$ }) => {
  // After setting up the network, we can tell MUD to start the synchronization process.
  startSync();

  const actions = createActionSystem<{ actionType: string }>(world, txReduced$);

  function init() {
    actions.add({
      id: "init" as EntityID,
      metadata: { actionType: "init" },
      requirement: () => true,
      components: {},
      execute: () => systems["system.Init"].executeTyped(),
      updates: () => [],
    });
  }

  function paint(coord: Coord) {
    actions.add({
      id: `paint ${coord.x}-${coord.y}` as EntityID,
      metadata: { actionType: "paint" },
      requirement: () =>
        getEntitiesWithValue(components.Position, coord).size == 0,
      components: {},
      execute: () => systems["system.Paint"].executeTyped(coord),
      updates: () => [],
    });
  }

  function paintRect(a: Coord, b: Coord) {
    const tl = { x: Math.min(a.x, b.x), y: Math.min(a.y, b.y) } as Coord;
    const br = { x: Math.max(a.x, b.x), y: Math.max(a.y, b.y) } as Coord;
    actions.add({
      id: `paint rect ${tl.x}-${tl.y} ${br.x}-${br.y}` as EntityID,
      metadata: { actionType: "paintRect" },
      requirement: () => true,
      components: {},
      execute: () =>
        systems["system.PaintRect"].executeTyped({ min: tl, max: br }),
      updates: () => [],
    });
  }

  // TODO: paintRect => colorRect
  (window as any).init = () => init();
  (window as any).paint = (x: number, y: number) => paint({ x, y });
  (window as any).paintRect = (
    x1: number,
    y1: number,
    x2: number,
    y2: number
  ) => paintRect({ x: x1, y: y1 }, { x: x2, y: y2 });

  let lastCoord: Coord | null = null;
  canvas.addEventListener("mousedown", function (event) {
    const coord = clickToCoord(event);
    if (event.button == 0) {
      paint(coord);
    } else if (event.button == 2) {
      if (lastCoord) {
        drawRect(canvasContext(), lastCoord.x, lastCoord.y, coord.x, coord.y);
        setTimeout(render, 500);
        paintRect(lastCoord, coord);
        lastCoord = null;
      } else {
        lastCoord = coord;
      }
    }
    return false;
  });
});
