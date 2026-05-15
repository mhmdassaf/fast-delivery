---
name: overflow-prevention
description: Prevent 'overflowed by X pixels' RenderFlex overflow errors in Flutter layouts
license: MIT
compatibility: opencode
metadata:
  audience: flutter-developers
  workflow: flutter
---

## What I do

Prevent "A RenderFlex overflowed by X pixels on the right/bottom" errors in Flutter layouts by enforcing defensive layout patterns. This skill is invoked when you write any Row, Column, Flex, or custom layout widget.

## The Golden Rules (Always Apply)

### Rule 1: Protect ALL Text Widgets
Every `Text` widget in a layout Row/Column MUST have `maxLines` + `TextOverflow.ellipsis`:

```dart
// ❌ BAD — text will overflow when content is long
Text('$ratingCount'),

// ✅ GOOD — text is constrained and will not overflow
Text(
  '$ratingCount',
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),
```

### Rule 2: Use Flexible/Expanded Inside Every Row/Column
Never put bare child widgets in a Row/Column without flex wrapping if they might exceed available space:

```dart
// ❌ BAD — fixed-width children will overflow
Row(
  children: [
    SomeFixedWidthWidget(),   // 80dp
    SizedBox(width: 16),      // 16dp
    AnotherFixedWidthWidget(),// 70dp
  ],
)

// ✅ GOOD — flexible children share remaining space
Row(
  children: [
    SomeFixedWidthWidget(),           // keeps its size
    SizedBox(width: 8),
    Flexible(child: AnotherWidget()), // shrinks if needed
    SizedBox(width: 8),
    Flexible(child: ThirdWidget()),   // shrinks if needed
  ],
)
```

### Rule 3: Never Rely on Spacer() to Prevent Overflow
`Spacer()` inside a Row only distributes **remaining** space. If children already overflow the constraints, `Spacer` contributes zero and overflow still happens:

```dart
// ❌ BAD — Spacer is useless when children overflow
Row(
  children: [
    WideWidgetA(),  // 200dp
    SizedBox(width: 16),
    WideWidgetB(),  // 200dp
    Spacer(),       // 0dp (no space left)
    WideWidgetC(),  // 200dp — OVERFLOW!
  ],
)

// ✅ GOOD — use flexible children to shrink content
Row(
  children: [
    Flexible(child: WideWidgetA()),
    SizedBox(width: 8),
    Flexible(child: WideWidgetB()),
    SizedBox(width: 8),
    Flexible(child: WideWidgetC()),
  ],
)
```

### Rule 4: LayoutBuilder for Responsive Layouts
When a widget must adapt to different screen widths, use `LayoutBuilder`:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 360) {
      return _CompactLayout();
    }
    return _ExpandedLayout();
  },
)
```

### Rule 5: Single-Column Lists Over Multi-Column Grids
For card-based layouts displaying text + images, prefer a single-column `ListView` over a multi-column `GridView`. Cards at full width have ~400+ dp of content area — more than enough for all text without overflow:

```dart
// ✅ GOOD — single column, full width, no overflow
ListView.builder(
  itemBuilder: (context, index) => ShopCard(...),
)

// ⚠️ USE WITH CAUTION — multi-column grid constrains cards to ~180dp
// each; requires Flexible everywhere inside the card
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.72,
  ),
  itemBuilder: (context, index) => ShopCard(...),
)
```

## Common Overflow Patterns & Fixes

### Pattern A: Card Content Row Overflows
**Symptom**: A Row in the bottom of a card with rating + delivery info + spacer overflows.

**Fix**: Use `Flexible` for variable-width items, reduce spacing, and ensure all Text has `maxLines: 1` + `overflow: TextOverflow.ellipsis`.

```dart
Row(
  children: [
    _RatingBadge(rating: 4.5, ratingCount: 123),
    const SizedBox(width: 4),                          // reduced from 16dp
    Flexible(child: _DeliveryInfo(label: '30-45 min')),
    const SizedBox(width: 4),
    Flexible(child: _DeliveryInfo(label: '\$2.99')),
  ],
)
```

### Pattern B: Skeleton/Loading Placeholder Overflows
**Symptom**: Shimmer skeleton has a Row of fixed-width bars that overflow.

**Fix**: Use fractional widths (percentages of available space) instead of fixed dp values, or match the actual card's layout precisely.

```dart
// ❌ BAD — fixed 80+16+60+16+50 = 222dp, but width is only 184dp
Row(
  children: [
    _SkeletonBar(width: 80),
    SizedBox(width: 16),
    _SkeletonBar(width: 60),
    SizedBox(width: 16),
    _SkeletonBar(width: 50),
  ],
)

// ✅ GOOD — match the actual card's layout
Row(
  children: [
    _SkeletonBar(width: 80),
    Spacer(),
    _SkeletonBar(width: 60),
    Spacer(),
    _SkeletonBar(width: 50),
  ],
)
```

## Overflow Detection Checklist

Before merging any widget with a Row/Column/Flex, verify:

- [ ] Every `Text` widget has `maxLines` + `overflow: TextOverflow.ellipsis`
- [ ] No fixed-width child exceeds 50% of estimated available width
- [ ] `Spacer` is not relied on to prevent overflow
- [ ] Flexible/Expanded is used for children that could be long
- [ ] Skeleton/loading placeholders match the real widget's layout
- [ ] Layout works at 320dp width (iPhone SE) — the smallest common size
- [ ] The widget does not assume a minimum width from its parent

## Testing for Overflow

1. **Run on a small-screen device** (emulate iPhone SE at 320dp width)
2. **Use long text content** to verify `TextOverflow.ellipsis` kicks in
3. **Check debug output** for "overflowed by X pixels" messages
4. **Run `flutter analyze`** to catch basic issues
5. **Test skeleton/loading states** — they often have different layout code than the real widget
