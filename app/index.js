const Koa = require("koa");
const app = new Koa();

app.proxy = true;

app.use(async (ctx) => {
  const msg = `${new Date().toISOString().substr(0, 19)} - your ip -> ${
    ctx.ip
  }\n${JSON.stringify(ctx.headers, null, "  ")}`;
  console.log(msg);
  ctx.body = msg;
});

app.listen(3000);
