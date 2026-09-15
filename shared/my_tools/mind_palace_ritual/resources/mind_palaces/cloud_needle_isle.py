from .models import MindPalace, Room

# Mind palace to practice the major system
# each object represents one of the 100 pair of possible digits
# e.g 01 = seed, 02 = sun

mind_palace = MindPalace(
    name="Cloud Needle Isle",
    rooms=[
        Room(
            room_name="Dawn Pier",
            description=(
                "The cloud landing where you arrive at dawn. A seed the size of your "
                "fist is planted in the middle of the decking and a sumo stands "
                "guarding it. At the edge there is a sofa facing out into the void."
            ),
            objects=[
                "seed",
                "sun",
                "sumo",
                "sir",
                "soul",
                "sushi",
                "sock",
                "sofa",
                "soap",
                "dice",
            ],
        ),
        Room(
            room_name="Hall of the Ancestors",
            description=(
                "A corridor of portraits climbing down from the pier. The first one is "
                "your dad, wired into a tall ladder of DNA. The last frame holds "
                "nothing but an enormous nose."
            ),
            objects=[
                "dad",
                "DNA",
                "Adam",
                "Thor",
                "tail",
                "DJ",
                "dog",
                "TV",
                "tuba",
                "nose",
            ],
        ),
        Room(
            room_name="Wharf of the Nets",
            description=(
                "A plank wharf hanging off the edge of the island. A net is spread "
                "across the floor and a nun kneels sewing in the middle of it. A "
                "knife is driven into the post."
            ),
            objects=[
                "net",
                "nun",
                "Nemo",
                "winner",
                "nail",
                "nacho",
                "ink",
                "knife",
                "NBA",
                "mouse",
            ],
        ),
        Room(
            room_name="Moon Arcade",
            description=(
                "A vaulted arcade with the moon caught in the glass ceiling. Mario "
                "runs the first machine. On the table at the back there is a map of "
                "the island lying open."
            ),
            objects=[
                "mat",
                "moon",
                "mommy",
                "Mario",
                "mule",
                "match",
                "Mickey",
                "mafia",
                "map",
                "rose",
            ],
        ),
        Room(
            room_name="Storm Roof",
            description=(
                "The top of the arcade, where the island meets the weather. A radio "
                "crackles on the parapet and a stone arm reaches out over the void. A "
                "lasso hangs tied to the chimney."
            ),
            objects=[
                "radio",
                "rain",
                "arm",
                "error",
                "Ariel",
                "arch",
                "rocky",
                "roof",
                "harp",
                "lasso",
            ],
        ),
        Room(
            room_name="Boiling Lagoon",
            description=(
                "You land beside a steaming lagoon. A lady in a robe stands at the "
                "front of the queue with a lion sitting behind her. Half the water is "
                "clear and the other half is red lava."
            ),
            objects=[
                "lady",
                "lion",
                "llama",
                "lawyer",
                "lolly",
                "leach",
                "lake",
                "lava",
                "lip",
                "cheese",
            ],
        ),
        Room(
            room_name="Bubbling Kitchen",
            description=(
                "The kitchen that feeds the island, dug into the rock behind the "
                "lagoon. A cheetah carries the plates out through the door and the "
                "chef stands at the pass, red from shouting. On the shelf there is a "
                "goose watching the action."
            ),
            objects=[
                "cheetah",
                "genie",
                "jam",
                "cherry",
                "chili",
                "yo-yo",
                "check",
                "chef",
                "chip",
                "goose",
            ],
        ),
        Room(
            room_name="Getaway Garage",
            description=(
                "Behind the kitchen, the garage that keeps the island's getaway "
                "vehicle. A cat sleeps on the workbench next to a gun. The car is up "
                "on blocks in the middle of the floor."
            ),
            objects=[
                "cat",
                "gun",
                "gum",
                "car",
                "koala",
                "cage",
                "cake",
                "coffee",
                "cube",
                "face",
            ],
        ),
        Room(
            room_name="Foam Beach",
            description=(
                "The garage ramp runs down to a beach of white cloud. The food table "
                "is the closest thing to you, with a big fan at one end of it blowing "
                "the foam about. Further out a fire is burning."
            ),
            objects=[
                "food",
                "fan",
                "foam",
                "fire",
                "fly",
                "fish",
                "foca",
                "FIFA",
                "Phoebe",
                "bass",
            ],
        ),
        Room(
            room_name="Thunder Orchard",
            description=(
                "The orchard at the summit, above every cloud. A bat hangs from the "
                "first branch and an open piano stands underneath it. Zeus sits on "
                "the wall at the far end."
            ),
            objects=[
                "bat",
                "piano",
                "beam",
                "bear",
                "apple",
                "bush",
                "pig",
                "beef",
                "baby",
                "Zeus",
            ],
        ),
    ],
)
