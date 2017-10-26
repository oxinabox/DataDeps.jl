using DataDeps
using Base.Test

# write your own tests here
function dummydown(remotepath, localpath)
    open(localpath,"w") do
        write(remotepath)
    end
    localpath
end

RegisterDataDep(
 "Test1",
 "http://www.example.com/eg.zip", # the remote-path to fetch it from, normally an URL. Passed to the `fetch_method`
 md5"aa674eb1ffb744954a45f2460666b469", #A hash that is used to check the data is right.
 ;
 fetch_method = download # the method used to fetch the data -- defaults to `download`, takes remote-path as its first argument and localpath as its last.
 post_fetch_method = unzip # A function that is applied to local filepath from fetch_method, to get do any post processing. Defaults to `indentity`
 extra_message ="""This is an extra message to be shown before downloading file"""
)
