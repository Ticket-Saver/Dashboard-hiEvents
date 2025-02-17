import { Tickets } from "./components/routes/event/tickets";

// ... otras importaciones

export const routes = [
  {
    path: "/manage/event/:eventId/tickets",
    element: <Tickets />,
  },
  // ... otras rutas
]; 