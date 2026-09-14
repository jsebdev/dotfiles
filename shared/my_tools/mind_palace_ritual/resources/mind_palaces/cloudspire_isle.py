from .models import MindPalace, Room

mind_palace = MindPalace(
    name="Cloudspire Isle",
    rooms=[
        Room(
            room_name="Sunrise Landing",
            description=(
                "The sky dock where you arrive at dawn. A glowing seed is planted in "
                "the middle of the deck and drinks the first sun. A sumo and a sir in "
                "a top hat bow to each other over it, and the soul of the isle drifts "
                "past while they share sushi. Behind them the whole sky opens up, and "
                "someone has dragged a sofa to the very edge, a bar of soap and a pair "
                "of dice left on its cushions."
            ),
            objects=[
                "seed",
                "sun",
                "sumo",
                "sir",
                "soul",
                "sushi",
                "sky",
                "sofa",
                "soap",
                "dice",
            ],
        ),
        Room(
            room_name="Hall of Forefathers",
            description=(
                "A corridor of portraits climbing away from the dock. Your dad hangs "
                "first, wired to a DNA ladder that runs down to Adam and up to Thor, "
                "whose hammer has grown a tail. Halfway along, a DJ spins with his dog "
                "asleep under the decks, facing a wall of stacked TVs. A tuba rests in "
                "the corner, and the last portrait is nothing but an enormous nose."
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
            room_name="Netmender's Pier",
            description=(
                "A plank pier hanging off the rim of the isle, where the rain nets are "
                "repaired. A net is spread across the boards, a nun sits mending it, "
                "and Nemo flaps in the mesh. A winner's trophy props the gate open, "
                "held up by a single nail. On the workbench sit a tray of nachos, a "
                "spilled pot of ink and the knife that cuts the cord. The mender keeps "
                "score on an NBA hoop nailed to the post, and a mouse steals crumbs "
                "underneath it."
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
            room_name="Moonlit Arcade",
            description=(
                "A vaulted arcade lit only from above. A welcome mat at the entry, the "
                "moon itself caught in the glass ceiling, and your mommy waiting under "
                "it. Mario runs the first cabinet, and past him the corridor widens "
                "into a little mall where a lit match hangs in a glass case and Mickey "
                "waves from the fountain. In the back booth the mafia argues over a map "
                "of the isle, and one of them wears a red rose."
            ),
            objects=[
                "mat",
                "moon",
                "mommy",
                "Mario",
                "mall",
                "match",
                "Mickey",
                "mafia",
                "map",
                "rose",
            ],
        ),
        Room(
            room_name="Stormwatch Roof",
            description=(
                "The arcade's roof, where the isle meets the weather. A crackling radio "
                "calls the rain in, a giant stone arm reaches out to catch it, and the "
                "screen bolted beside it blinks ERROR. Ariel shelters under the arch. "
                "Past her the tiles turn rocky, then break into open roof. A harp is "
                "left out in the storm, still ringing, and a lasso is tied to the "
                "chimney so you can swing down."
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
                "You land beside a steaming lagoon. A lady in a bathrobe is first in "
                "line, a lion and a llama queue behind her, and a lawyer reads the "
                "terms out loud before anyone is allowed in, until he is bribed with a "
                "lolly. The lich runs the baths. Half the water is cool lake and half "
                "is lava, the shore curls like a lip, and the snack raft floating in "
                "the middle carries one enormous wheel of cheese."
            ),
            objects=[
                "lady",
                "lion",
                "llama",
                "lawyer",
                "lolly",
                "lich",
                "lake",
                "lava",
                "lip",
                "cheese",
            ],
        ),
        Room(
            room_name="Bubbling Kitchen",
            description=(
                "The kitchen that feeds the isle, carved into the rock behind the "
                "lagoon. A cheetah runs the plates out the door. A genie pours from the "
                "jam jar, sets one cherry on top, and a chili bobs in the pot beside "
                "him. Jojo is on washing up. The check is spiked on the pass, the chef "
                "shouts over it, a single chip has been dropped on the floor, and the "
                "goose waits at the back door for it."
            ),
            objects=[
                "cheetah",
                "genie",
                "jam",
                "cherry",
                "chili",
                "jojo",
                "check",
                "chef",
                "chip",
                "goose",
            ],
        ),
        Room(
            room_name="Getaway Garage",
            description=(
                "Behind the kitchen, the garage that keeps the escape run ready. A cat "
                "sleeps on the toolbench beside a gun, a wad of chewed gum stuck to its "
                "handle. The car is up on blocks with a koala asleep at the wheel and a "
                "cage bolted into the trunk, a cake sitting inside the cage. The "
                "mechanic's coffee has gone cold on the roof next to a melting ice "
                "cube, and the hubcap is polished bright enough to show you your own "
                "face."
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
                "The garage ramp drops onto a beach of cloud foam. The food table comes "
                "first, a huge fan blowing the foam back off it, and the foam itself "
                "piled waist deep beyond. A fire burns in the middle with a fly "
                "circling it, a fish on the spit, and a foca clapping for a bite. The "
                "nets are up for a FIFA match on the sand, Phoebe keeps goal, and a "
                "bass guitar is plugged in beside her post."
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
                "The summit orchard, above every cloud. A bat hangs from the first "
                "branch. A piano sits under it, and every key it strikes throws a beam "
                "of lightning. A bear stands on its hind legs to reach the apple, a "
                "bush at its feet, a pig rooting through the bush, and a side of beef "
                "hung up to smoke. A baby sleeps in the roots of the last tree, and "
                "Zeus sits on the wall, watching the whole isle beneath him."
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
