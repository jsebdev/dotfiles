---
name: software-designer-mindset
description: Apply 7 principles of modern software design (composition over inheritance, high cohesion, low coupling, start with the data, depend on abstractions, separate creation from use, keep things simple) when writing, reviewing, or refactoring code. Use when designing new features, structuring modules, reviewing pull requests, or refactoring existing code toward cleaner architecture.
---

# Software Designer Mindset

Apply these 7 principles of modern software design when writing, reviewing, or refactoring code. They are listed in order of priority when conflicts arise.

## 1. Keep Things Simple (KISS)

Write the simplest solution that solves the current problem. Avoid speculative abstractions.

**Rules:**

- No code "just in case" — solve what's needed now
- Prefer flat over nested, explicit over clever
- If a junior dev can't follow it in 60 seconds, simplify it

**Apply when:** Starting any new feature, choosing between approaches, or during code review.

**Watch for:** Over-engineering, premature optimization, unnecessary design patterns.

## 2. Start with the Data

Design your data structures and schemas first. The right data model makes algorithms obvious; the wrong one makes everything painful.

**Rules:**

- Define your core entities, their attributes, and relationships before writing logic
- Let the data shape drive the API and module boundaries
- Use value objects and typed structures (dataclasses, TypedDict, Pydantic) to make data explicit
- Wrap primitives in domain types — a `CustomerId` and a `ShopId` are both strings, but they are not interchangeable
- Make invalid states unrepresentable: if mixing two types is a bug, make it a compile/type error instead

**Apply when:** Designing a new feature, defining database models, planning an API.

**Watch for:** Logic-first thinking that forces awkward data transformations later. Functions with multiple parameters of the same primitive type (e.g., `def transfer(from_id: str, to_id: str)`) — these invite silent argument swaps that no type checker will catch.

**Domain type examples:**

```python
from typing import NewType

CustomerId = NewType("CustomerId", int)
ShopId = NewType("ShopId", int)

def get_orders(customer_id: CustomerId, shop_id: ShopId): ...

# This is now a type error — swap is caught by the type checker
get_orders(shop_id, customer_id)
```

```typescript
type CustomerId = string & { readonly _brand: "CustomerId" };
type ShopId = string & { readonly _brand: "ShopId" };

function getOrders(customerId: CustomerId, shopId: ShopId): void {}

// Type error — cannot assign ShopId to CustomerId
getOrders(shopId, customerId);
```

The overhead is 2–5 lines per type. The benefit is compiler-enforced correctness, self-documenting signatures, and safe refactoring across the codebase.

## 3. High Cohesion

High cohesion means that a module, class, or function should have a single, well-defined responsibility — all its parts should be closely related and working toward the same purpose. A cohesive unit does one thing and does it well, making code easier to understand, test, and maintain.
**How to implement it:**

- Group together only what truly belongs together
- Split classes or functions that handle multiple unrelated concerns
- Name each unit clearly so its single purpose is obvious
- Ask yourself: "Do all the parts of this class/function serve the same goal?"
  **Desired outcome:** Each component is self-contained, focused, and can be changed or tested without ripple effects across unrelated logic.
  **Wrong example** — low cohesion, one class doing too many unrelated things:

```python
class UserManager:
    def create_user(self, name, email): ...
    def send_welcome_email(self, email): ...
    def hash_password(self, password): ...
    def generate_pdf_report(self, users): ...
    def log_activity(self, message): ...
```

`UserManager` is responsible for user creation, email sending, password hashing, PDF generation, and logging — completely unrelated concerns bundled together.
**Correct example** — high cohesion, each class has a focused purpose:

```python
class UserRepository:
    def create_user(self, name, email): ...
    def get_user(self, user_id): ...
    def delete_user(self, user_id): ...

class PasswordService:
    def hash_password(self, password): ...
    def verify_password(self, password, hash): ...

class EmailService:
    def send_welcome_email(self, email): ...
    def send_reset_email(self, email): ...

class ReportService:
    def generate_pdf_report(self, users): ...
```

Each class owns a single concern. Changes to email logic don't touch user storage, and password rules don't bleed into reporting.

## 4. Low Coupling

Low coupling means modules are independent from each other, making them easier to reuse, modify, and test. Aim to minimize dependencies between components.

### Coupling Types (Worst to Best)

**Content & Global Coupling (Avoid Always)**

- Never access or modify another module's internal data directly
- Never use global variables for shared state
- Prefer composition over inheritance
- Add methods to enforce encapsulation — no reaching into private internals
  **Import & External Coupling (Use Abstraction)**
- Never depend directly on external libraries or services in business logic
- Define ABCs or Protocols as boundaries between your code and third-party dependencies
- Wrap external services behind interfaces so they are replaceable without changing consumers
  **Control Coupling (Split Responsibilities)**
- Avoid use boolean flags to switch method behavior
- If a function does different things based on an input flag, split it into separate functions
- Each function should have a single clear responsibility
  **Stamp/Data Structure Coupling (Narrow Interfaces)**
- Never pass complex data structures to code that only needs part of them
- Define Protocols or small dataclasses for the specific data a function needs
- Functions should receive only the data they actually use
  **Message Coupling (Ideal)**
- Components communicate only through well-defined, minimal interfaces
- This is the loosest and best form of coupling

### Law of Demeter (Principle of Least Knowledge)

A unit should only talk to its immediate collaborators. Avoid chained calls like `order.customer.address.city` — instead, ask the direct collaborator for what you need.

### Quick Rules

- If replacing a dependency requires changes across multiple modules, coupling is too high
- If you cannot test a module without setting up unrelated components, coupling is too high
- When in doubt, add an interface between the two sides

## 5. Prefer Composition Over Inheritance

Composition over inheritance means that instead of building behavior by extending a parent class, you build it by combining smaller, focused objects that each handle a specific responsibility. Rather than asking "what is this thing?", you ask "what can this thing do?" — and then plug in the right pieces. Inheritance creates tight coupling between parent and child classes, making changes risky and hierarchies hard to extend. Composition keeps things flexible by letting you swap behaviors independently.
**How to implement it:**

- Avoid deep inheritance chains (more than 2 levels is a warning sign)
- Extract behaviors into separate classes or services
- Inject dependencies rather than inheriting them
- Favor "has-a" relationships over "is-a" relationships
  **Desired outcome:** Classes are loosely coupled, behaviors are reusable across unrelated classes, and adding new functionality doesn't require restructuring the hierarchy.
  **Wrong example** — using inheritance to share behavior, creating rigid coupling:

```python
class Animal:
    def breathe(self): ...
    def swim(self): ...
    def fly(self): ...

class Duck(Animal):
    pass  # Inherits fly and swim — fine

class Penguin(Animal):
    pass  # Also inherits fly — but penguins can't fly!

class FlyingFish(Animal):
    pass  # Inherits breathe, swim, fly — but is it really an Animal in this hierarchy?
```

The parent class bundles unrelated behaviors, and subclasses are forced to inherit things they shouldn't have.
**Correct example** — composing behavior from focused, reusable pieces:

```python
class Swimmer:
    def swim(self): ...

class Flyer:
    def fly(self): ...

class Breather:
    def breathe(self): ...


class Duck:
    def __init__(self):
        self.swimmer = Swimmer()
        self.flyer = Flyer()
        self.breather = Breather()

class Penguin:
    def __init__(self):
        self.swimmer = Swimmer()
        self.breather = Breather()
        # No Flyer — because penguins don't fly

class FlyingFish:
    def __init__(self):
        self.swimmer = Swimmer()
        self.flyer = Flyer()
```

Each class only gets the behaviors it actually needs. Adding a new capability (like `Diver`) doesn't touch existing classes at all.

## 6. Depend on Abstractions

High-level modules should not depend on low-level details. Both should depend on abstractions (protocols, interfaces, ABCs).

**Rules:**

- Define protocols/interfaces for external boundaries (DB, APIs, email, storage)
- Import abstractions, not implementations
- Use dependency injection to wire concrete classes at the composition root

**Example:**

```python
from typing import Protocol

class PaymentGateway(Protocol):
    def charge(self, amount: Money) -> ChargeResult: ...

# The service depends on the protocol, not on Stripe directly
class CheckoutService:
    def __init__(self, gateway: PaymentGateway): ...
```

**Apply when:** Integrating with external services, writing testable code, designing plugin points.

**Watch for:** Direct imports of third-party SDKs deep in business logic, hard-to-mock dependencies.

---

## 7. Separate Creation from Use

The code that **creates** objects should be different from the code that **uses** them. This is the practical application of dependency injection.

**Rules:**

- Business logic receives its dependencies — it never instantiates them
- Centralize object creation in a composition root, factory, or framework config (e.g., Django settings, FastAPI `Depends`)
- Tests become trivial: just pass fakes/stubs to the constructor

**Example:**

```python
# creation (composition root / config)
gateway = StripeGateway(api_key=settings.STRIPE_KEY)
service = CheckoutService(gateway=gateway)

# use (business logic — no knowledge of how gateway was built)
result = service.checkout(cart)
```

**Apply when:** Wiring up services, configuring app startup, writing tests.

**Watch for:** `import` + instantiate inside business functions, hidden global state, singletons used to avoid DI.

---

## Quick Reference: When Principles Conflict

| Conflict                       | Resolution                                                                                                          |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| Abstraction vs. Simplicity     | Don't abstract until you have 2+ concrete cases                                                                     |
| Low Coupling vs. High Cohesion | Cohesion wins — a cohesive module with a clear interface is better than scattering related logic to reduce coupling |
| Composition vs. Simplicity     | If a single-level inheritance is the simplest solution and there's a true is-a relationship, use it                 |

## How to Use This Skill

When asked to design, write, or review code:

1. **Start with the data** — define entities and relationships first
2. **Structure for cohesion** — group related logic, split unrelated logic
3. **Minimize coupling** — define narrow interfaces between modules
4. **Compose, don't inherit** — build behavior from small parts
5. **Abstract at boundaries** — depend on protocols for external integrations
6. **Separate creation from use** — inject dependencies, centralize wiring
7. **Sanity-check simplicity** — if the design feels heavy, pare it back
