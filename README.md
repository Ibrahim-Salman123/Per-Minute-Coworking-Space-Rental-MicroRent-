A precision, real-time micro-billing asset sharing and rental smart contract built on Ethereum using Solidity. It uses block timestamps to track usage, enabling pay-as-you-go leasing for physical resources.

📌 Overview
The MicroRent smart contract provides a modern utility engine for granular, pay-as-you-go asset sharing, optimized for coworking desks, specialized tools, and IoT automation hardware. Traditional leasing options enforce rigid hourly or daily flat fees, forcing users to pay for unused blocks of time. This contract removes that inefficiency by calculating rental fees down to the minute using immutable block timestamps. External IoT devices (like smart locks) can read contract states to automate check-ins and check-outs, processing precise micro-billings with zero administrative friction.

🛠 Features
Granular Time-Slice Billing: Tracks usage durations down to the second, ensuring consumers only pay for the exact minutes they use an asset.

Integrated Deposit Refund Architecture: Accepts upfront funding caps, deducts the precise rental cost, and automatically returns the remaining excess balance back to the user in a single transaction.

IoT Hardware Compatibility: Can easily link with smart door locks or internet-connected machines, allowing automated access control based on live on-chain check-in statuses.

📄 Smart Contract Architecture
Data Structures
RentalSession (Struct)
Tracks active usage metrics per tenant:

startTime: The block timestamp marking the exact second a tenant initializes access.

isActive: A boolean safety valve indicating whether the leasing session is currently live.

State Variables
provider: The address of the facility owner or asset operator who collects the usage fees.

ratePerMinute: The cost threshold in Wei charged for every 60 seconds of active lease usage.

activeSessions: A public mapping (address => RentalSession) tracking current tenant check-in states.

⚙️ Core Functions
1. checkIn()
Permission: Public

Description: Starts a live rental tracking session for the caller. Validates that the user does not already have an active session before logging block.timestamp as their start time.

2. checkOut()
Permission: Public Payable

Description: Ends the rental session. It calculates the elapsed minutes, multiplies them by ratePerMinute to find the totalCost, keeps the rental fee for the provider, and immediately returns any remaining excess deposit back to the tenant. If a user exits immediately, it rounds the charge up to 1 minute to cover the minimum base interface fee.

3. updateRate(uint256 _newRate)
Permission: Only provider

Description: Allows facility management to dynamically adjust unit pricing structures based on real-time demand or electricity overhead changes.

🔔 Events
CheckedIn(address indexed user, uint256 startTime): Emitted the moment a tenant checks in, signaling hardware systems to unlock physical access.

CheckedOut(address indexed user, uint256 durationMinutes, uint256 totalCost, uint256 refundAmount): Emitted upon checkout completion, providing an immutable receipt log of the entire usage event.

RateUpdated(uint256 newRate): Emitted when facility management changes the asset rental pricing.

🚀 Tech Stack & Setup
Language: Solidity ^0.8.20

Tools: Remix IDE / Hardhat / Foundry

Standard Deploy Instructions: Open your compiler workspace, paste MicroRent.sol, select compiler version 0.8.20, and deploy. The deploying address is automatically configured as the fee-receiving asset provider.
