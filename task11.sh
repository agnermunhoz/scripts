#!/bin/bash
export id=$1
docker run hello-world
docker images
docker run hello-world
docker ps
docker ps -a
mkdir test && cd test
cat > Dockerfile <<EOF
# Use an official Node runtime as the parent image
FROM node:6
# Set the working directory in the container to /app
WORKDIR /app
# Copy the current directory contents into the container at /app
ADD . /app
# Make the container's port 80 available to the outside world
EXPOSE 80
# Run app.js using node when the container launches
CMD ["node", "app.js"]
EOF
cat > app.js <<EOF
const http = require('http');
const hostname = '0.0.0.0';
const port = 80;
const server = http.createServer((req, res) => {
    res.statusCode = 200;
      res.setHeader('Content-Type', 'text/plain');
        res.end('Welcome to Cloud\n');
});
server.listen(port, hostname, () => {
    console.log('Server running at http://%s:%s/', hostname, port);
});
process.on('SIGINT', function() {
    console.log('Caught interrupt signal and will exit');
    process.exit();
});
EOF
docker build -t node-app:0.1 .
docker images
docker run -p 4000:80 --name my-app node-app:0.1 &
curl http://localhost:4000
docker stop my-app && docker rm my-app
docker run -p 4000:80 --name my-app -d node-app:0.1
docker ps
docker logs my-app
docker build -t node-app:0.2 .
docker run -p 8080:80 --name my-app-2 -d node-app:0.2
docker ps
curl http://localhost:8080
curl http://localhost:4000
docker logs my-app-2
docker exec -it my-app-2 bash
ls
exit
docker inspect my-app-2
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' my-app-2
docker tag node-app:0.2 gcr.io/$id/node-app:0.2
docker images
docker push gcr.io/$id/node-app:0.2
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
docker rmi node-app:0.2 gcr.io/$id/node-app node-app:0.1
docker rmi node:6
docker rmi $(docker images -aq) # remove remaining images
docker images
docker pull gcr.io/$id/node-app:0.2
docker run -p 4000:80 -d gcr.io/$id/node-app:0.2
curl http://localhost:4000
