# Apple Books Reader UI - Phase 1

This change focuses on the reader chrome only.

## Changed
- Removed the old full-width floating top toolbar.
- Removed the old full-width floating bottom action toolbar.
- Added a standalone upper-right close control.
- Added a standalone lower-right reading menu control.
- Moved Contents, Bookmark, Read Aloud, AI and Reading Settings into one reading menu.
- Preserved immersive reading when controls are hidden.
- Kept existing reader business logic and callbacks intact.
- Updated reader chrome widget tests for the new interaction model.

## Not changed yet
- Detailed Themes & Settings sheet layout.
- Navigation/contents sheet visual redesign.
- Search-in-book entry.
- Previous-reading-location return control.
- Exact Apple Books transition motion and gesture tuning.
