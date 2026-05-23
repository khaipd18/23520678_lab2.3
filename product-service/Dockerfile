FROM node:18-alpine
WORKDIR /app
RUN npm install express
COPY index.js .
EXPOSE 3002
CMD ["node", "index.js"]