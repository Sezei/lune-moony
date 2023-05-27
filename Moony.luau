--LUNEMETA
--NAME Moony
--DESCR A Lune networking wrapper made for serving API pages.
--AUTHOR Sezei
--VER PROD_0
--ENDLUNEMETA

local Moony = {};

local Enums = {
    ReponseStatus = {
        ["OK"] = 200;
        ["CREATED"] = 201;
        ["ACCEPTED"] = 202;
        ["NO_CONTENT"] = 204;
        ["MOVED_PERMANENTLY"] = 301;
        ["FOUND"] = 302;
        ["NOT_MODIFIED"] = 304;
        ["TEMPORARY_REDIRECT"] = 307;
        ["PERMANENT_REDIRECT"] = 308;
        ["BAD_REQUEST"] = 400;
        ["UNAUTHORIZED"] = 401;
        ["FORBIDDEN"] = 403;
        ["NOT_FOUND"] = 404;
        ["METHOD_NOT_ALLOWED"] = 405;
        ["NOT_ACCEPTABLE"] = 406;
        ["REQUEST_TIMEOUT"] = 408;
        ["CONFLICT"] = 409;
        ["GONE"] = 410;
        ["LENGTH_REQUIRED"] = 411;
        ["PAYLOAD_TOO_LARGE"] = 413;
        ["URI_TOO_LONG"] = 414;
        ["UNSUPPORTED_MEDIA_TYPE"] = 415;
        ["RANGE_NOT_SATISFIABLE"] = 416;
        ["EXPECTATION_FAILED"] = 417;
        ["IM_A_TEAPOT"] = 418;
        ["UNPROCESSABLE_ENTITY"] = 422;
        ["TOO_MANY_REQUESTS"] = 429;
        ["INTERNAL_SERVER_ERROR"] = 500;
        ["NOT_IMPLEMENTED"] = 501;
        ["BAD_GATEWAY"] = 502;
        ["SERVICE_UNAVAILABLE"] = 503;
        ["GATEWAY_TIMEOUT"] = 504;
        ["HTTP_VERSION_NOT_SUPPORTED"] = 505;
    };
};

Moony.Enums = Enums;

Moony.jsonEncode = function(string)
    return serde.encode('json', string);
end;

Moony.jsonDecode = function(string)
    return serde.decode('json', string);
end;

Moony.app = function()
    local app = {server = nil; gets = {}; posts = {}; patches = {}; deletes = {}; puts = {}; default = nil;};

    app.get = function(path, request) --> Will be called when specifically a GET request is made to the path. Path is relative to the root of the server (aka '/')
        app.gets[path] = request
    end
    
    app.post = function(path, request) --> Will be called when specifically a POST request is made to the path. Path is relative to the root of the server (aka '/')
        app.posts[path] = request
    end
    
    app.patch = function(path, request) --> Will be called when specifically a PATCH request is made to the path. Path is relative to the root of the server (aka '/')
        app.patches[path] = request
    end
    
    app.delete = function(path, request) --> Will be called when specifically a DELETE request is made to the path. Path is relative to the root of the server (aka '/')
        app.deletes[path] = request
    end
    
    app.put = function(path, request) --> Will be called when specifically a PUT request is made to the path. Path is relative to the root of the server (aka '/')
        app.puts[path] = request
    end

    app.default = function(request) --> Will be called when a path is not found. Useful for 404 errors
        return {
            status = Enums.ReponseStatus.NOT_FOUND;
            body = "Not Found";
            headers = {
                ["Content-Type"] = "text/plain";
            };
        };
    end
    
    app.start = function(port, startcallback)
        app.server = net.serve(port, function(request)
            local method = request.method;
            local path = request.path;
    
            local response = nil;
            local pathfound = false; -- Don't return a false 404 if the path is found but responded with nothing
    
            if method == "GET" then
                if app.gets[path] then
                    response = app.gets[path](request);
                    pathfound = true;
                end
            elseif method == "POST" then
                if app.posts[path] then
                    response = app.posts[path](request);
                    pathfound = true;
                end
            elseif method == "PATCH" then
                if app.patches[path] then
                    response = app.patches[path](request);
                    pathfound = true;
                end
            elseif method == "DELETE" then
                if app.deletes[path] then
                    response = app.deletes[path](request);
                    pathfound = true;
                end
            elseif method == "PUT" then
                if app.puts[path] then
                    response = app.puts[path](request);
                    pathfound = true;
                end
            end
    
            if not pathfound then
                response = app.default(request);
            end

            if not response then
                -- Return a blank response if nothing is returned
                response = {
                    status = Enums.ReponseStatus.NO_CONTENT;
                    body = "";
                    headers = {
                        ["Content-Type"] = "text/plain";
                    };
                };
            end;

            response.headers["Content-Length"] = #response.body;
            response.headers['X-Powered-By'] = "Lune / Moony";
            
            return response; -- net already handles the response stuff, we just return it
        end);
    
        if startcallback then startcallback(app.server) end;
    end

    app.stop = function()
        if app.server then
            app.server.stop();
        end
    end

    return app;
end;

return Moony
