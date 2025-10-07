# UI/UX Design Specification: NDA ↔ Lil Nouns Governance Bridge

## 🎨 Design Overview

This document outlines the frontend design specifications for the NDA ↔ Lil Nouns Governance Bridge web application. The interface enables NDA token holders on Base to vote on mirrored Lil Nouns proposals with a clean, intuitive, and accessible user experience.

---

## 🎯 Design Principles

1. **Clarity First**: Information hierarchy that makes governance participation obvious
2. **Trust & Transparency**: Clear status indicators for cross-chain operations
3. **Accessibility**: WCAG 2.1 AA compliant, mobile-responsive
4. **Progressive Disclosure**: Show complexity only when needed
5. **Nouns Aesthetic**: Aligned with Nouns DAO visual language while maintaining unique NDA identity

---

## 🎨 Visual Identity

### Color Palette

**Primary Colors**
- `#FF00FF` - Primary CTA (NDA Purple)
- `#00FFFF` - Secondary (Base Blue)
- `#FFD700` - Accent (Lil Nouns Yellow)
- `#1A1A1A` - Background Dark
- `#FFFFFF` - Background Light

**Status Colors**
- `#00FF00` - Success (Vote Succeeded, Executed)
- `#FF4444` - Error/Defeated
- `#FFA500` - Warning/Pending
- `#808080` - Inactive/Closed

**Semantic Colors**
- For: `#00C853` (Green)
- Against: `#FF1744` (Red)
- Abstain: `#FFB300` (Amber)

### Typography

**Font Stack**
```css
--font-primary: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
--font-mono: 'JetBrains Mono', 'Fira Code', monospace;
--font-display: 'Space Grotesk', sans-serif;
```

**Type Scale**
- Display: 48px / 56px (Proposal titles)
- H1: 36px / 44px (Page headers)
- H2: 28px / 36px (Section headers)
- H3: 20px / 28px (Card headers)
- Body: 16px / 24px (Primary text)
- Small: 14px / 20px (Secondary text)
- Micro: 12px / 16px (Labels, timestamps)

### Spacing System

```css
--space-xs: 4px;
--space-sm: 8px;
--space-md: 16px;
--space-lg: 24px;
--space-xl: 32px;
--space-2xl: 48px;
--space-3xl: 64px;
```

### Border Radius
```css
--radius-sm: 4px;
--radius-md: 8px;
--radius-lg: 12px;
--radius-xl: 16px;
--radius-full: 9999px;
```

---

## 📱 Layout Structure

### Header (Sticky)

```
┌─────────────────────────────────────────────────────┐
│  [Logo] NDA ↔ Lil Nouns Bridge     [Network Badge]  │
│                                                       │
│  [Proposals] [History] [Docs]   [Connect Wallet]    │
└─────────────────────────────────────────────────────┘
```

**Components:**
- Logo/Brand: NDA + Lil Nouns combined mark
- Navigation: Proposals (default), Voting History, Documentation
- Network Indicator: Current chain (Base/Ethereum) with switcher
- Wallet Connect: MetaMask, WalletConnect, Coinbase Wallet
- Voting Power Display: "X votes" badge when connected

### Main Container

**Desktop**: Max-width 1200px, centered
**Tablet**: Max-width 100%, padding 24px
**Mobile**: Full width, padding 16px

---

## 🗂️ Page Layouts

### 1. Proposals Page (Home)

#### Hero Section
```
┌────────────────────────────────────────────────┐
│  🗳️ NDA ↔ Lil Nouns Governance Bridge          │
│                                                │
│  Vote on Lil Nouns proposals from Base with    │
│  your NDA tokens. Cross-chain voting made      │
│  simple and secure.                            │
│                                                │
│  [Your Voting Power: 42 votes] [View Stats →] │
└────────────────────────────────────────────────┘
```

#### Filter Bar
```
┌────────────────────────────────────────────────┐
│ [All] [Active] [Succeeded] [Defeated] [Finalized] │
│                                    [🔍 Search]  │
└────────────────────────────────────────────────┘
```

#### Proposal List (Card Grid)

Each proposal card:
```
┌─────────────────────────────────────────────┐
│ [STATUS BADGE]              [Chain: Base 🔵] │
│                                              │
│ Proposal #123                                │
│ Add 100 ETH to Treasury                      │
│                                              │
│ ┌─────────────────────────────────────────┐ │
│ │ For: 1,234 (62%)    ███████████░░░░░░   │ │
│ │ Against: 543 (27%)  █████░░░░░░░░░░░░   │ │
│ │ Abstain: 221 (11%)  ██░░░░░░░░░░░░░░░   │ │
│ └─────────────────────────────────────────┘ │
│                                              │
│ ⏱️ Ends in 2d 14h        [View Details →]    │
└─────────────────────────────────────────────┘
```

**Status Badges:**
- 🟢 Active (pulsing animation)
- 🟡 Pending
- ✅ Succeeded
- ❌ Defeated
- 🔗 Finalized (with mainnet link)

### 2. Proposal Detail Page

#### Header Section
```
┌──────────────────────────────────────────────────┐
│ [← Back to Proposals]                             │
│                                                   │
│ Proposal #123                          [🟢 Active]│
│ Add 100 ETH to Treasury for Development          │
│                                                   │
│ Proposed by: 0x1234...5678                       │
│ Voting Period: Dec 1, 2025 - Dec 8, 2025        │
└──────────────────────────────────────────────────┘
```

#### Two-Column Layout

**Left Column (66%):**

##### Proposal Description
```
┌────────────────────────────────────────┐
│ 📄 Description                          │
│                                        │
│ This proposal requests 100 ETH from    │
│ the treasury to fund...                │
│                                        │
│ [Read Full Proposal on IPFS →]        │
└────────────────────────────────────────┘
```

##### Actions/Transactions
```
┌────────────────────────────────────────┐
│ ⚙️ Actions (3)                          │
│                                        │
│ 1. Transfer 100 ETH                    │
│    To: 0xAbcd...Ef12                   │
│                                        │
│ 2. Update Parameters                   │
│    Contract: TreasuryManager           │
│                                        │
│ [View Technical Details ↓]             │
└────────────────────────────────────────┘
```

##### Discussion (Optional)
```
┌────────────────────────────────────────┐
│ 💬 Discussion                          │
│                                        │
│ [Link to Discourse/Forum →]            │
└────────────────────────────────────────┘
```

**Right Column (33%):**

##### Vote Status
```
┌────────────────────────────────────────┐
│ 🗳️ Vote Status                         │
│                                        │
│ Total Votes: 1,998 / 3,200             │
│ Quorum: 640 (20%) ✅                   │
│                                        │
│ ┌──────────────────────────────────┐  │
│ │ For                              │  │
│ │ 1,234 votes (62%)                │  │
│ │ ████████████████████░░░░░░░░░░  │  │
│ └──────────────────────────────────┘  │
│                                        │
│ ┌──────────────────────────────────┐  │
│ │ Against                          │  │
│ │ 543 votes (27%)                  │  │
│ │ ███████░░░░░░░░░░░░░░░░░░░░░░░░  │  │
│ └──────────────────────────────────┘  │
│                                        │
│ ┌──────────────────────────────────┐  │
│ │ Abstain                          │  │
│ │ 221 votes (11%)                  │  │
│ │ ███░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  │
│ └──────────────────────────────────┘  │
└────────────────────────────────────────┘
```

##### Cast Your Vote (if Active)
```
┌────────────────────────────────────────┐
│ 🗳️ Cast Your Vote                      │
│                                        │
│ Your Voting Power: 42 votes            │
│                                        │
│ ┌────────────┐                        │
│ │    For     │ [Radio selected]       │
│ └────────────┘                        │
│                                        │
│ ┌────────────┐                        │
│ │  Against   │ [Radio]                │
│ └────────────┘                        │
│                                        │
│ ┌────────────┐                        │
│ │  Abstain   │ [Radio]                │
│ └────────────┘                        │
│                                        │
│ [Add Reason (Optional)] ┐             │
│ │                       │             │
│ └───────────────────────┘             │
│                                        │
│ [Cast Vote on Base →]                 │
│ (Estimated gas: ~0.001 ETH)           │
└────────────────────────────────────────┘
```

##### Cross-Chain Status
```
┌────────────────────────────────────────┐
│ 🔗 Cross-Chain Status                  │
│                                        │
│ Base Vote:                             │
│ ✅ Finalized (Block 12,345,678)        │
│                                        │
│ Layer-0 Message:                       │
│ ✅ Delivered                           │
│ [View on LayerZero Scan →]            │
│                                        │
│ Mainnet Execution:                     │
│ ✅ Vote Cast (Tx: 0xAbc...123)        │
│ [View on Etherscan →]                 │
└────────────────────────────────────────┘
```

### 3. Voting History Page

#### User's Vote History
```
┌──────────────────────────────────────────────────────┐
│ Your Voting History                                  │
│                                                      │
│ Total Votes Cast: 23                                │
│ Participation Rate: 87%                             │
└──────────────────────────────────────────────────────┘

[Table View]
┌────┬──────────────────┬──────────┬────────┬──────────┐
│ #  │ Proposal         │ Your Vote│ Result │ Date     │
├────┼──────────────────┼──────────┼────────┼──────────┤
│ 123│ Add 100 ETH...   │ For ✅   │ Pass ✅ │ Dec 1    │
│ 122│ Update Quorum    │ Against ❌│ Fail ❌│ Nov 28   │
│ 121│ New Member       │ Abstain ⚪│ Pass ✅ │ Nov 25   │
└────┴──────────────────┴──────────┴────────┴──────────┘
```

---

## 🎭 Components Library

### 1. Wallet Connection Modal

```
┌─────────────────────────────────────┐
│  Connect Wallet              [X]    │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ [🦊 MetaMask]                 │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ [🔗 WalletConnect]            │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ [🔵 Coinbase Wallet]          │ │
│  └───────────────────────────────┘ │
│                                     │
│  By connecting, you agree to our   │
│  Terms of Service                  │
└─────────────────────────────────────┘
```

### 2. Network Switcher

```
┌─────────────────────────────────────┐
│  Switch Network              [X]    │
│                                     │
│  ⚠️ Please switch to Base            │
│                                     │
│  Current: Ethereum Mainnet          │
│  Required: Base                     │
│                                     │
│  [Switch to Base →]                │
└─────────────────────────────────────┘
```

### 3. Transaction Status Toast

**Pending:**
```
┌─────────────────────────────────────┐
│ ⏳ Casting your vote...              │
│ [Progress Spinner]                  │
│ [View on Basescan →]               │
└─────────────────────────────────────┘
```

**Success:**
```
┌─────────────────────────────────────┐
│ ✅ Vote cast successfully!           │
│ Your vote has been recorded on Base │
│ [View Transaction →]                │
└─────────────────────────────────────┘
```

**Error:**
```
┌─────────────────────────────────────┐
│ ❌ Transaction failed                │
│ Reason: Insufficient gas            │
│ [Try Again] [Dismiss]              │
└─────────────────────────────────────┘
```

### 4. Vote Power Indicator

```
┌──────────────────────────┐
│ 🗳️ Your Voting Power      │
│                          │
│    42 votes              │
│                          │
│ Based on 42 NDA tokens   │
│ [View Details →]         │
└──────────────────────────┘
```

### 5. Proposal Status Badge

```
[🟢 Active]    [🟡 Pending]    [✅ Succeeded]
[❌ Defeated]  [🔗 Finalized]  [⏸️ Canceled]
```

---

## 📊 Data Visualization

### Vote Distribution Chart

**Horizontal Bar Chart:**
- For: Green bar with percentage and vote count
- Against: Red bar with percentage and vote count
- Abstain: Amber bar with percentage and vote count
- Animated on load (bars grow from 0%)

**Donut Chart (Alternative):**
- Total votes in center
- Segments: For (green), Against (red), Abstain (amber)
- Hover shows exact vote count

### Participation Metrics

```
┌────────────────────────────────────┐
│ 📊 Participation Metrics            │
│                                    │
│ Total Eligible Voters: 3,200      │
│ Votes Cast: 1,998 (62%)           │
│ Quorum Required: 640 (20%)        │
│                                    │
│ [████████████░░░░░░░] 62%         │
└────────────────────────────────────┘
```

---

## 🔄 State Management & Flow

### Voting Flow

1. **Initial State (Not Connected)**
   - Show "Connect Wallet" CTA
   - Display proposal info as read-only

2. **Connected (Wrong Network)**
   - Show network switcher modal
   - Disable voting actions

3. **Connected (Correct Network, No Voting Power)**
   - Show message: "You need NDA tokens to vote"
   - Link to get NDA tokens

4. **Connected (Has Voting Power, Active Proposal)**
   - Show voting interface
   - Display user's voting power
   - Enable vote casting

5. **Vote Submitted**
   - Show pending state with transaction hash
   - Disable re-voting
   - Update to success/error state

6. **Vote Confirmed**
   - Update UI with user's vote
   - Show in voting history
   - Display cross-chain status

### Cross-Chain Status Flow

```
Base Vote → Layer-0 Message → Mainnet Execution
   ✅           ⏳                  ⏳

Timeline:
1. Vote on Base (immediate)
2. Layer-0 message sent (~30s)
3. Mainnet execution (~2min)
```

**Status Indicators:**
- ⏳ Pending (animated spinner)
- ✅ Complete (checkmark)
- ❌ Failed (with retry option)
- 🔄 Retrying

---

## 📱 Responsive Design

### Breakpoints

```css
--mobile: 320px - 767px
--tablet: 768px - 1023px
--desktop: 1024px+
```

### Mobile Adaptations

1. **Header:**
   - Hamburger menu for navigation
   - Wallet address truncated: "0x12...AB"
   - Network badge moves to dropdown

2. **Proposal Cards:**
   - Stack vertically
   - Full width
   - Collapsed vote bars (expandable)

3. **Proposal Detail:**
   - Single column layout
   - Vote panel sticky at bottom
   - Action buttons full width

4. **Voting History:**
   - Card view instead of table
   - Swipe for more details

---

## ♿ Accessibility

### WCAG 2.1 AA Compliance

1. **Color Contrast:**
   - Text: Minimum 4.5:1
   - UI Components: Minimum 3:1

2. **Keyboard Navigation:**
   - All interactive elements tabbable
   - Clear focus indicators
   - Escape to close modals

3. **Screen Readers:**
   - Semantic HTML
   - ARIA labels for complex components
   - Alt text for all images/icons

4. **Motion:**
   - Respect `prefers-reduced-motion`
   - Option to disable animations

### Focus States

```css
:focus-visible {
  outline: 2px solid var(--primary);
  outline-offset: 2px;
}
```

---

## 🎬 Animations & Transitions

### Micro-interactions

1. **Button Hover:**
   ```css
   transform: translateY(-2px);
   box-shadow: 0 4px 12px rgba(0,0,0,0.15);
   transition: all 0.2s ease;
   ```

2. **Card Hover:**
   ```css
   transform: translateY(-4px);
   box-shadow: 0 8px 24px rgba(0,0,0,0.12);
   ```

3. **Vote Bar Animation:**
   ```css
   @keyframes growBar {
     from { width: 0%; }
     to { width: var(--percentage); }
   }
   animation: growBar 1s ease-out;
   ```

4. **Status Badge Pulse (Active):**
   ```css
   @keyframes pulse {
     0%, 100% { opacity: 1; }
     50% { opacity: 0.6; }
   }
   ```

### Page Transitions

- Fade in: 300ms
- Slide up: 400ms (modals)
- Skeleton loading for async content

---

## 🔔 Notifications & Feedback

### Toast Notifications

**Position:** Top-right (desktop), top-center (mobile)

**Types:**
1. Success (green)
2. Error (red)
3. Warning (amber)
4. Info (blue)

**Auto-dismiss:** 5 seconds (closeable)

### In-line Validation

- Real-time for form inputs
- Show errors below fields
- Success checkmarks for valid inputs

### Loading States

1. **Skeleton Screens:**
   - Proposal cards
   - Vote data
   - History table

2. **Spinners:**
   - Transaction pending
   - Data fetching

3. **Progress Bars:**
   - Multi-step processes
   - Upload progress

---

## 🧪 Testing & Quality Assurance

### Cross-Browser Testing
- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

### Device Testing
- iPhone (13+)
- Android (recent models)
- iPad
- Desktop (various resolutions)

### Performance Targets
- LCP: < 2.5s
- FID: < 100ms
- CLS: < 0.1
- Bundle size: < 200KB (initial)

---

## 📝 Content Guidelines

### Tone of Voice
- Clear and concise
- Friendly but professional
- Avoid jargon when possible
- Explain technical terms in tooltips

### Error Messages
❌ "Transaction failed"
✅ "Your vote couldn't be submitted. Please check your wallet and try again."

❌ "Invalid input"
✅ "Please enter a whole number for your vote."

### Empty States
```
No active proposals right now
New proposals appear here when created on Lil Nouns DAO
[View Past Proposals →]
```

---

## 🔮 Future Enhancements

### Phase 2 Features
- Dark mode toggle
- Multiple language support
- Delegation interface
- Proposal creation (if governance allows)
- Advanced analytics dashboard
- Push notifications (web push)
- ENS name display
- NFT avatar display

### Advanced Features
- Vote simulation (estimate outcome)
- Historical data charts
- Governance participation leaderboard
- Discord/Telegram integration
- Mobile app (React Native)

---

## 📚 Resources & Assets

### Design Files
- Figma: [Link to designs]
- Icons: Heroicons, Lucide Icons
- Illustrations: Custom + Nouns library

### Documentation
- Component Storybook
- Design tokens JSON
- Accessibility audit report

### Brand Assets
- NDA logo (SVG)
- Lil Nouns logo (SVG)
- Color palette (Figma/Tokens)

---

**Document Version:** 1.0
**Last Updated:** 2025-10-08
**Status:** Phase 1 Design Specification
