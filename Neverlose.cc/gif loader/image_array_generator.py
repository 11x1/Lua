images = [
    "frame-url",
    "frame2-url",
    # etc, dont forget comma
]

frame = 0
print("local frames = {")
for image in images:
    print("    Http.Get('" + images[frame] + "'),")
    frame += 1
print("}")
