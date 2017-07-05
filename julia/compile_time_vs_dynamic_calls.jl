#
# Use: 
#  start Julia and type
#    include("compile_time_vs_dynamic_calls.jl")


"""
  # Dynamic runtime-call vs. compile-time resolve

  Let's talk about the difference of runtime-calls and
  compile-time calls in Julia with the help of two examples.
  """
const introduction = nothing


"""
  ## Example 1

        type FuncContainer
          func :: Function
        end

  This is a container for *some* function. At compile-time
  Julia only knows that *some* function is saved in the
  field `func`.

  This has consequences, when this field is used:

  """
type FuncContainer
        func :: Function
end

"""
        function call_func_in_FuncContainer(c::FuncContainer)
          return c.func(0.5)
        end

  This simple function takes a `FuncContainer` and calls the
  (packed) function with the argument `0.5`.

  *But keep in mind*: At the time Julia is compiling this
  function, no additonal information about `func` is known.
  `func` can be *any* subtype of `Function`. Hence
  Julia produces some "generic" function-call code (called a
  dynamic runtime-call).

  """
function call_func_in_FuncContainer(c::FuncContainer)
        return c.func(0.5)
end

"""
        function example1()
          cont = FuncContainer(sin)
          print(call_func_in_FuncContainer(cont),"\\n")
          code_native(call_func_in_FuncContainer, (typeof(cont),))
        end

  Let's see this in action together with the code that was compiled.
  """
function example1()
        cont = FuncContainer(sin)
        print(call_func_in_FuncContainer(cont),"\n")
        code_native(call_func_in_FuncContainer, (typeof(cont),))
end


"""
  ## Example 2

        type TypedFuncContainer{FUNC_TYPE<:Function}
          func :: FUNC_TYPE
        end

  This is a parameterized/typed container for a very specific
  function type `FUNC_TYPE` (which is a subtype of `Function`).

  This has consequences, when this field is used:
  """
type TypedFuncContainer{FUNC_TYPE<:Function}
        func :: FUNC_TYPE
end

"""
        function call_func_in_TypedFuncContainer(c::TypedFuncContainer)
          return c.func(0.5)
        end
  
  This simple function takes a `TypedFuncContainer` and calls the
  function stored in the field `func` with the argument `0.5`.

  *Keep in mind*: At compile-time Julia knows the specific 
  `FUNC_TYPE`, because `FUNC_TYPE` is part of the
  `TypedFuncContainer`. Hence Julia knows exactly what function
  is saved in the field `func` and can resolve the call at
  compile-time.
  """
function call_func_in_TypedFuncContainer(c::TypedFuncContainer)
        return c.func(0.5)
end

"""
        function example2()
          cont = TypedFuncContainer(sin)
          print(call_func_in_TypedFuncContainer(cont),"\\n")
          code_native(call_func_in_TypedFuncContainer, (typeof(cont),))
        end

  Let's see this in action together with the code that was compiled.
  """
function example2()
        cont = TypedFuncContainer(sin)
        print(call_func_in_TypedFuncContainer(cont),"\n")
        code_native(call_func_in_TypedFuncContainer, (typeof(cont),))
end

display.([ @doc(introduction), 
           @doc(FuncContainer), @doc(call_func_in_FuncContainer),
           @doc(example1) ])
example1()


display.([ @doc(TypedFuncContainer), @doc(call_func_in_TypedFuncContainer),
           @doc(example2) ])
example2()


# vim:syn=julia:cc=79:fdm=indent:
