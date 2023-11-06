# Salbi Faza Rinaldi
# Gunakan `python:3.11.4` sebagai base image
FROM python:3.11

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install needed packages in requirements.txt
RUN pip install -r requirements.txt


EXPOSE 6000

CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "6000"]