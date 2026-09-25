from dataclasses import dataclass


@dataclass(frozen=True)
class MilestoneLadder:
    opening: tuple[int, ...] = (10, 20, 50, 100)
    step: int = 100

    def milestones_up_to(self, distance: int) -> list[int]:
        milestones = [milestone for milestone in self.opening if milestone <= distance]
        next_milestone = self.opening[-1] + self.step
        while next_milestone <= distance:
            milestones.append(next_milestone)
            next_milestone += self.step
        return milestones

    def is_milestone(self, count: int) -> bool:
        return count in self.milestones_up_to(count)


DIGIT_MILESTONES = MilestoneLadder()
