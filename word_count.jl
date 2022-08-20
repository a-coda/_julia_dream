# See http://a-coda.tumblr.com/
 
function find_files ( root, extension )
    for filename in readdir( root )
        fullname = joinpath( root, filename )
        if isdir( fullname )
            find_files( fullname, extension )
        elseif endswith( fullname, extension )
            produce( fullname )
        end
    end
end
 
function produce_from ( iterable )
    for i in iterable
        produce( i )
    end
end
 
function find_lines ( filename )
    open( filename ) do stream
        produce_from( eachline( stream ) )
    end
end
 
function find_words ( filename )
    for line in @task find_lines( filename ) 
        produce_from( split( line ) )
    end
end
 
function count_words ( filename )
    accumulate( @task find_words( filename ) )
end
 
function accumulate ( objects )
    counts = Dict{String,Int}()
    function accumulate! ( key::String, value=1 )
        counts[ key ] = get(counts, key, 0) + value
    end
    function accumulate! ( object::Dict )
        for key in keys( object )
            accumulate!( key, object[key] )
        end
    end
    for object in objects
        accumulate!( object )
    end
    counts
end
 
function main ()
    start = time()
    files = @task find_files( ".", ".java" )
    file_counts = pmap( count_words, files )
    counts = accumulate( file_counts )
    common = collect( keys( counts ) )
    sort!( common, by=x->counts[x], rev=true )
    finish = time()
    for word in common[1:20]
        println( "$word = $(counts[word])" )
    end
    println( "files: $( length( file_counts ) )" )
    println( "words: $( length( counts ) )" )
    println( "time: $( finish - start )" )
end
