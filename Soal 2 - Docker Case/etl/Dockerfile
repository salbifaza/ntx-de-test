# Gunakan `python:3.11.4` sebagai base image
# Salbi Faza Rinaldi

FROM python:3.11

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt

# Define the command to run your ETL script
CMD ["python", "etl.py"]