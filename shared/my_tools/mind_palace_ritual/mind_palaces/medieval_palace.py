from .models import MindPalace, Room

mind_palace = MindPalace(
    name="Medieval Palace",
    rooms=[
        Room(
            room_name="Armory",
            objects=[
                "knight armor",
                "open chest",
                "bow rack",
                "hand weapons",
                "shields"
            ],
        ),
        Room(
            room_name="Food Storage",
            objects=[
                "water vases",
                "grain sacks",
                "food shelf",
                "ham leg",
                "cheese",
                "sausages",
                "crates",
                "bread basket",
                "corked bottle",
                "barrel rack"
            ],
        ),
        Room(
            room_name="Snack Room",
            objects=[
                "cabinet",
                "small candelabrum",
                "round table",
                "grapes",
                "wine jar"
            ]
        )
    ],
)
