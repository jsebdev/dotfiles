from .models import MindPalace, Room

mind_palace = MindPalace(
    name="Maze",
    rooms=[
        Room(
            room_name="Meditation Zone",
            objects=[
                "balanced stones",
                "meditation mat",
                "floating candles",
                "bonsai tree",
                "stone lantern",
            ],
        ),
        Room(
            room_name="Fountain",
            objects=[
                "fountain",
                "garden table",
                "bench swing",
                "pillow",
                "unicorn statue",
            ],
        ),
        Room(
            room_name="Picnic",
            objects=[
                "bicycle",
                "garden umbrella",
                "blanket",
                "food basket",
                "folding chair",
            ],
        ),
        Room(
            room_name="Druid place",
            objects=[
                "druid staff",
                "stone table",
                "sickle",
                "bag of herbs",
                "menhir stone"
            ],
        ),
        Room(
            room_name="Robber's hideout",
            objects=[
                "rope",
                "lockpicks",
                "pouch with coins",
                "target",
                "bonfire pot",
                "bow",
                "quiver",
                "robber's cap",
                "hammock",
                "leather boots"
            ],
        ),
    ],
)
