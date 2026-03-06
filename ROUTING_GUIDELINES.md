# Routing Guidelines

## Adding a New Route

1. Create a routes file in your module: `lib/modules/your-module/routes/your_module_routes.dart`
2. Define route names and paths as constants
3. Create a function that returns `List<GoRoute>`
4. Import and spread your routes in `app_routes.dart`

## Route Naming Convention

- Use kebab-case for paths: `/user-profile`, `/add-review`
- Use camelCase for route names: `userProfile`, `addReview`
- Group related routes: `/reviews`, `/reviews/add`, `/reviews/:id`

## Navigation Best Practices

- ALWAYS use `AppRoutes` constants, never hardcode strings
- Use `AppNavigator` helper methods when possible
- For simple navigation, use `context.goNamed()` or `context.pushNamed()`
- Always handle optional parameters gracefully

## Route Parameters

- Path parameters: Use for required IDs: `/reviews/:id`
- Query parameters: Use for filters/sorting: `/reviews?sort=date`
- Extra: Use for complex objects: `extra: myObject`
