module SearchLightODBC

using ODBC
using SearchLight
using Logging
using DataFrames
using DBInterface

const DatabaseHandle = ODBC.Connection

const CONNECTIONS = DatabaseHandle[]

"""
    adddriver(drivername::String, driverpath::String)

Add a driver to the ODBC driver manager. This is a wrapper around OBCD.addDriver: see the ODBC.jl documentation for more details.

# Example
```julia
julia> if Sys.islinux()
          if Int == Int32
              libpath = joinpath(expanduser("~"), "mariadb32/lib/libmaodbc.so")
          else
              libpath = joinpath("/home/runner/mariadb64", "mariadb-connector-odbc-3.1.11-ubuntu-focal-amd64/lib64/mariadb/libmaodbc.so")
          end
       elseif Sys.iswindows()
          if Int == Int32
            libpath = expanduser(joinpath("~", "mariadb-connector-odbc-3.1.7-win32", "maodbc.dll"))
          else
            @show readdir(expanduser(joinpath("~", "mariadb-connector-odbc-3.1.7-win64", "SourceDir", "MariaDB", "MariaDB ODBC Driver 64-bit")))
            libpath = expanduser(joinpath("~", "mariadb-connector-odbc-3.1.7-win64", "SourceDir", "MariaDB", "MariaDB ODBC Driver 64-bit", "maodbc.dll"))
          end
       else
          libpath = MariaDB_Connector_ODBC_jll.libmaodbc_path
       end

julia> SearchLightODBC.adddriver("ODBC_Test_MariaDB", libpath)
```
"""
function adddriver(drivername::String, driverpath::String; kw...)
    ODBC.addDriver(drivername, driverpath; kw...)
end

"""
    viewdrivers()

View installed drivers
"""
function viewdrivers()
  ODBC.drivers()
end

"""
    adddsn(;kw...)
  
Add a DSN to the ODBC driver manager. This is a wrapper around OBCD.adddsn: see the ODBC.jl documentation for more details.

# Example
```julia
julia> SearchLightODBC.adddsn(name = "ODBC_Test_DSN_MariaDB", driver = "ODBC_Test_MariaDB";SERVER="127.0.0.1", UID="root", PLUGIN_DIR=PLUGIN_DIR, Option=67108864, CHARSET="utf8mb4")
```
"""
function adddsn(name::String, driver::String; kw...)
  ODBC.adddsn(name, driver; kw...)
end

"""
    connect(conndata::String)::DatabaseHandle
    function connect()::DatabaseHandle
Connects to the database with data source name `dsn` and returns a `DatabaseHandle`.

where `conndata` is a string of the form `"Driver={ODBC_Test_MariaDB};SERVER=127.0.0.1;PLUGIN_DIR=\$PLUGIN_DIR;Option=67108864;CHARSET=utf8mb4;USER=root"` ODBC_Test_MariaDB
just name of driver if you have already added it to the ODBC driver manager. `"mysql_test"` is the name of the DSN you have already added to the ODBC driver manager.

# Example
```julia
julia> con = SearchLightODBC.connect("ODBC_Test_DSN_MariaDB")
```
"""
function SearchLight.connect(conndata::String)::DatabaseHandle
  push!(CONNECTIONS, DBInterface.connect(ODBC.Connection, conndata))[end]
end

"""
    disconnect(conn::DatabaseHandle)::Nothing
Disconnects from database.
"""
function SearchLight.disconnect(conn::DatabaseHandle = SearchLight.connection()) :: Nothing
  @info "running disconnect"
  DBInterface.close!(conn)
end

function SearchLight.connection()
  isempty(CONNECTIONS) && throw(SearchLight.Exceptions.NotConnectedException())

  CONNECTIONS[end]
end



end # module SearchLightODBC
