local Moony = require('./Moony');
local app = Moony.app();

app.get('/', function(request)
    print("CONNECT!")
    return {
        status = Moony.Enums.ReponseStatus.OK;
        body = "Hello World!";
        headers = {
            ["Content-Type"] = "text/plain";
        };
    };
end);

app.start(8080, function()
    print("Test Server started on port 8080");
end);
