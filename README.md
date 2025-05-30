# 🚗 Tire Plug - QBCore (Smokey City Roleplay)

A lightweight tire repair script for QBCore servers using `ox_inventory`, `ox_target`, and `lib` UI notifications. Created by **Smokey** from **Smokey City Roleplay**.

---

## 🔧 Features

- Plug burst tires directly on vehicles
- Front-left, front-right, rear-left, and rear-right support
- Uses skill checks (via `lib.skillCheck`)
- Compatible with `xt-slashtires` (optional integration)
- Progress animation and immersive feedback
- Works with `ox_inventory`, `ox_target`, and `lib.notify`

---

## 📦 Dependencies

- [QBCore Framework](https://github.com/qbcore-framework/qb-core)
- [ox_inventory](https://overextended.dev/)
- [ox_target](https://overextended.dev/)
- [ox_lib](https://overextended.dev/)
- [xt-slashtires](https://github.com/XerxesSk/xt-slashtires) *(optional)*

---

## 📁 Installation

1. **Download** or **clone** the repository:
Add to your resources folder and ensure it's started in your server.cfg:


ensure tire_plug
Add the item to your ox_inventory items list:


{
    "name": "tire_plug",
    "label": "Tire Plug",
    "weight": 100,
    "type": "item",
    "image": "tire_plug.png",
    "unique": false,
    "useable": false,
    "shouldClose": true,
    "combinable": null,
    "description": "Use this to repair a burst tire."
}
(Optional) Make sure xt-slashtires is installed if you want slash repair support.

🧪 Usage
Approach a vehicle with a burst tire. If you have a Tire Plug item, an interaction option will show using ox_target.

Requires a successful skill check.

Animation and progress circle for realism.

Fails gracefully if no item is present or skill check fails.

👨‍🔧 Credits
Script Author: Smokey
Server: Smokey City Roleplay

🪪 License
This resource is open-source and free to use under the MIT License. Proper credit is appreciated.

💬 Support
For help or questions, open an issue on the GitHub repository or join the Smokey City RP Discord (link coming soon).








