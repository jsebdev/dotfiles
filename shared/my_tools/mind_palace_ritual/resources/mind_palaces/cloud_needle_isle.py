from .models import MindPalace, Room

# Mind palace to practice the major system
# each object represents one of the 100 pair of possible digits
# e.g 00 = Zeus, 01 = seed

mind_palace = MindPalace(
    name="Cloud Needle Isle",
    rooms=[
        Room(
            room_name="Thunder Pier",
            description=(
                "The cloud landing where you arrive at dawn. Zeus stands at the top "
                "of the gangway to welcome you, throwing thunder over the water. A "
                "seed the size of your fist is planted in the middle of the decking "
                "and a sumo stands guarding it. At the edge there is a sofa facing "
                "out into the void."
            ),
            objects=[
                "Zeus",
                "seed",
                "sun",
                "sumo",
                "sir",
                "soul",
                "sushi",
                "ski",
                "sofa",
                "soap",
            ],
        ),
        Room(
            room_name="Hall of the Ancestors",
            description=(
                "A corridor of portraits climbing up from the pier. A pair of giant "
                "dice sits at the entrance, blocking half the way in. The first "
                "portrait is your dad, wired into a tall ladder of DNA. At the far "
                "end a tuba leans against the last frame."
            ),
            objects=[
                "dice",
                "dad",
                "DNA",
                "Adam",
                "Thor",
                "tail",
                "DJ",
                "dog",
                "TV",
                "tuba",
            ],
        ),
        Room(
            room_name="Wharf of the Nets",
            description=(
                "A plank wharf hanging off the edge of the island. An enormous nose "
                "sniffs the air over the rail where the corridor comes out. A net is "
                "spread across the floor and a nun kneels sewing in the middle of "
                "it. A knife is driven into the post."
            ),
            objects=[
                "nose",
                "net",
                "nun",
                "Nemo",
                "winner",
                "nail",
                "nacho",
                "ink",
                "knife",
                "NBA",
            ],
        ),
        Room(
            room_name="Moon Arcade",
            description=(
                "A mouse waits on the mat at the door of a vaulted arcade, with the "
                "moon caught in the glass ceiling above it. On the table at the back "
                "there is a map of the island lying open."
            ),
            objects=[
                "mouse",
                "mat",
                "moon",
                "mummy",
                "Mario",
                "mule",
                "mochi",
                "Mickey",
                "mafia",
                "map",
            ],
        ),
        Room(
            room_name="Storm Roof",
            description=(
                "The top of the arcade, where the island meets the weather. A single "
                "rose grows out of a crack in the parapet, with a radio crackling "
                "beside it. Further along a stone arm points out to the sky, and a "
                "harp is lashed to the chimney."
            ),
            objects=[
                "rose",
                "radio",
                "iron",
                "arm",
                "error",
                "Ariel",
                "arch",
                "rocky",
                "roof",
                "harp",
            ],
        ),
        Room(
            room_name="Boiling Lagoon",
            description=(
                "You land beside a steaming lagoon. A lasso hangs coiled on the post "
                "at the water's edge. A lady in a robe stands at the front of the "
                "queue with a lion sitting behind her. Half the water is clear and "
                "the other half is red lava."
            ),
            objects=[
                "lasso",
                "lady",
                "lion",
                "llama",
                "lawyer",
                "lolly",
                "leach",
                "lock",
                "lava",
                "lip",
            ],
        ),
        Room(
            room_name="Bubbling Kitchen",
            description=(
                "The kitchen that feeds the island, dug into the rock behind the "
                "lagoon. A wheel of cheese blocks the doorway and a cheetah carries "
                "the plates out over it. A genie pours out of the pot on the stove. "
                "At the pass stands the chef, red from shouting."
            ),
            objects=[
                "cheese",
                "cheetah",
                "genie",
                "jam",
                "cherry",
                "chili",
                "yo yo",
                "check",
                "chef",
                "chip",
            ],
        ),
        Room(
            room_name="Getaway Garage",
            description=(
                "Behind the kitchen, the garage that keeps the island's getaway "
                "vehicle. A goose stands guard in the doorway. A cat sleeps on the "
                "workbench next to a gun. The car is up on blocks in the middle of "
                "the floor."
            ),
            objects=[
                "goose",
                "cat",
                "gun",
                "gum",
                "car",
                "koala",
                "cage",
                "cake",
                "coffee",
                "cube",
            ],
        ),
        Room(
            room_name="Foam Beach",
            description=(
                "The garage ramp runs down to a beach of white cloud. A huge stone "
                "face is carved into the rock at the bottom of the ramp. The food "
                "table is the closest thing to you, with a big fan at one end of it "
                "blowing the foam about."
            ),
            objects=[
                "face",
                "food",
                "fan",
                "foam",
                "fire",
                "fly",
                "fish",
                "foca",
                "FIFA",
                "Phoebe",
            ],
        ),
        Room(
            room_name="Summit Orchard",
            description=(
                "The orchard at the summit, above every cloud. A bass guitar leans "
                "against the trunk of the first tree and a bat hangs from the branch "
                "above it. An open piano stands underneath them. A baby sleeps on "
                "the wall at the far end."
            ),
            objects=[
                "bass",
                "bat",
                "piano",
                "beam",
                "bear",
                "apple",
                "bush",
                "pig",
                "beef",
                "baby",
            ],
        ),
    ],
)
