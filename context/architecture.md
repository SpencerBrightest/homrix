# Architecture Overview

## Multi-Sided Marketplace Actors

The platform operates as a peer-to-peer marketplace with three core roles:

### The Guest (Demand)
- Performs filtered searches with location, dates, guest count
- Applies filters: price range, property type, amenities, ratings
- Initiates secure booking transactions
- Tracks booking status in real-time
- Receives booking confirmations and updates via push notifications
- Manages payment methods and booking histories

### The Host (Supply)
- Creates and publishes listings with photos, descriptions, pricing
- Manages calendar availability (open/blocked dates)
- Overrides calendar parameters: minimum stay, cleaning fees, service fees
- Monitors real-time payout states and earnings
- Accepts/rejects booking requests
- Reviews guest profiles and booking histories

### The Platform Admin (Mediator)
- Oversees validation policies and community guidelines
- Reviews conflict resolution logs for disputed bookings
- Monitors service fee operations and platform revenue
- Manages user/host accounts and enforcement actions
- Accesses analytics dashboard for platform health metrics
- Configures AI orchestration policies and gateways

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    LOCAL CACHE LAYER (Source of Truth)          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Hive/Isar DB   │  │  JSON Cache     │  │  Stream Cache   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                   ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲
                   │  │  │  │  │  │  │  │  │  │  │  │  │
    OPTIMISTIC UI  │  │  │  │  │  │  │  │  │  │  │  │  │  LOCAL MODS
    (0ms latency)    │  │  │  │  │  │  │  │  │  │  │  │  │
                   │  │  │  │  │  │  │  │  │  │  │  │  │
┌─────────────────────────────────────────────────────────────────┐
│                    RIVERPOD LAYER                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ @riverpod       │  │ @riverpod       │  │ @riverpod       │ │
│  │ SearchState     │  │ ListingState    │  │ BookingState    │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                   ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲
                   │  │  │  │  │  │  │  │  │  │  │  │  │
              INVALIDATE│  │  │  │  │  │  │  │  │  │  │
    PULL-TO-REFRESH │  │  │  │  │  │  │  │  │  │  │
                   │  │  │  │  │  │  │  │  │  │  │  │  │
┌─────────────────────────────────────────────────────────────────┐
│                    REPOSITORY LAYER                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Local DataSource│  │ Remote DataSource│  │ Sync Queue      │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                   ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲  ▲
                   │  │  │  │  │  │  │  │  │  │  │  │  │
    CLOUD PERSISTENCE                              │  │  │
                                              BACKGROUND SYNC