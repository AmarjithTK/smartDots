
#!/usr/bin/python3


import tkinter as tk
from tkinter import filedialog





import csv
import os
import logging
from tkinter import *
from tkinter.filedialog import askopenfilename, asksaveasfilename, askdirectory
from moviepy.video.io.VideoFileClip import VideoFileClip
from moviepy.video.compositing.concatenate import concatenate_videoclips


# Function to convert timestamp to seconds
def timestamp_to_seconds(timestamp):
    h, m, s = timestamp.split(':')
    return int(h) * 3600 + int(m) * 60 + int(s)








def browse_input_file():
    global input_file
    input_file = filedialog.askopenfilename()
    input_file_label.config(text=input_file)

def browse_output_folder():
    global output_folder
    output_folder = filedialog.askdirectory()
    output_folder_label.config(text=output_folder)

def browse_csv_file():
    global csv_file
    csv_file = filedialog.askopenfilename()
    csv_file_label.config(text=csv_file)



def get_output_file_name():
    # foldername = askdirectory()
    # if not foldername:
        # Return a default filename in the current directory
        # foldername = output_folder
    output_filename = os.path.splitext(os.path.basename(input_file))[0] + "-cropped.mp4"
    output_file = os.path.join(output_folder, output_filename)
    # else:
    #     output_filename = os.path.splitext(os.path.basename(input_file))[0] + "-cropped.mp4"
    #     output_file = os.path.join(foldername, output_filename)

    # output_label_text.set(output_file)
    return output_file

# Function to create empty output file
def create_output_file(output_filename):
    open(output_filename, 'w').close()




def process_video():
    print("process video")
    log_textbox.insert(END, "Started processing video file...\n\n")
    logging.info("Writing output file...")


    if not input_file or not output_folder or not csv_file:
        print("process video not")
        return

    # Get timestamps from CSV file
    timestamps = []
    with open(csv_file, 'r') as f:
        reader = csv.reader(f)
        for row in reader:
            timestamps.append(row)
    print(timestamps)  

    log_textbox.insert(END, f"{timestamps} \n timestamp cropping now \n")
    logging.info("Writing output file...")
      

    # Convert timestamps to start and end times in seconds
    time_ranges = []
    for timestamp in timestamps:
        start = timestamp[0]
        end = timestamp[1]
        start_sec = timestamp_to_seconds(start)
        end_sec = timestamp_to_seconds(end)
        time_ranges.append((start_sec, end_sec))

    # Create subclips from the input video using the start and end times
    subclips = []
    for start, end in time_ranges:
        clip = VideoFileClip(input_file).subclip(start, end)
        subclips.append(clip)

    print(subclips)    
    log_textbox.insert(END, "Subclips formed successfully...\n")
    logging.info("Writing output file...")


    # Combine the subclips into a single output video
    output_file = get_output_file_name()

 

    # output_clip = concatenate_videoclips(subclips)


    # Combine the subclips into a single output video
    output_clip = concatenate_videoclips(subclips)

    # # Get the output file name from the user using a save dialog
    # output_file = asksaveasfilename(filetypes=[("MP4 Files", "*.mp4")], defaultextension=".mp4")
    # if output_file:
    #     output_file = os.path.abspath(output_file)
    #     output_label_text.set(output_file)

    # Write the output video to a file
    # output_clip.write_videofile(output_file)



    log_textbox.insert(END, "Writing output file...\n")
    logging.info("Writing output file...")
    output_clip.write_videofile(output_file)
    # output_clip.write_videofile(output_file)
    log_textbox.insert(END, "Output file written successfully!\n")
    logging.info("Output file written successfully!")

    
    # Process the video here
    # ...

root = tk.Tk()
root.title("Unnimash Youtube Cutter")
root.geometry("1280x720")



input_file = ""
output_folder = ""
csv_file = ""

input_file_button = tk.Button(root, text="Browse Input File", command=browse_input_file)
input_file_button.pack()
input_file_label = tk.Label(root, text="")
input_file_label.pack()

output_folder_button = tk.Button(root, text="Browse Output Folder", command=browse_output_folder)
output_folder_button.pack()
output_folder_label = tk.Label(root, text="")
output_folder_label.pack()

csv_file_button = tk.Button(root, text="Browse CSV File", command=browse_csv_file)
csv_file_button.pack()
csv_file_label = tk.Label(root, text="")
csv_file_label.pack()

process_video_button = tk.Button(root, text="Process Video", command=process_video)
process_video_button.pack()


log_frame = Frame(root)
log_frame.pack(side=TOP, fill=X)

log_label = Label(log_frame, text="Processing Logs:", font=("Arial", 14))
log_label.pack(side=TOP, pady=10)

log_textbox = Text(log_frame, height=10, width=100)
log_textbox.pack(padx=10, pady=10, fill=BOTH, expand=True)


# Center the items in the window
for child in root.winfo_children():
    child.pack_configure(padx=20, pady=20)

root.mainloop()
