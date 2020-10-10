#import Hash
defmodule Tapestry do
use GenServer
	def main do

 		if (Enum.count(System.argv())!=2) do
            IO.puts" Illegal Arguments Provided"
            System.halt(1)


		 else
 			[numNodes, numRequests] = System.argv()
 			{numNodes, _} = Integer.parse(numNodes)
 			{numRequests, _} = Integer.parse(numRequests)

 			pidHash = createNodes(numNodes)
 			if(numNodes <=500) do
 				Enum.map((1..numNodes), fn(x) ->
 				Task.async(Tapestry,:createRoutingTable, [Enum.at(pidHash,x-1),pidHash,numNodes,8, Map.new()])
 				#addMap(elem(Enum.at(pidHash,x-1),0),Task.await(map))
 				end)
 			else
 				Enum.map((1..numNodes), fn(x) ->
 					createRoutingTable(Enum.at(pidHash,x-1),pidHash,numNodes,8, Map.new())
 				end)
 			end

 			if(numNodes <= 100)	do
 				:timer.sleep(1000)
 			else if(numNodes <= 500) do
 				:timer.sleep(100000)

 			end
 			end

 			#IO.inspect (elem(Enum.at(pidHash, 0),0))
 			nodesPid = Enum.map((1..numNodes), fn(x) ->
				elem(Enum.at(pidHash,x-1),0)
			end)
			nodesHash = Enum.map((1..numNodes), fn(x) ->
				elem(Enum.at(pidHash,x-1),1)
			end)
			randNode = Enum.random(nodesPid)
 			#IO.inspect (getMap(randNode))
			object = "random object"
			#IO.inspect (getMap(objNode))
			#IO.puts "#{getHashVal(objNode)}"
 			rootHash = findRoot(object,numNodes,pidHash)
 			#IO.puts(rootHash)
 			ind = Enum.find_index(nodesHash, fn x -> x == rootHash end)
 			rootPid = Enum.at(nodesPid,ind)
 			#IO.inspect String.slice((:crypto.hash(:sha256, Kernel.inspect(rootPid)) |> Base.encode16),0..7)
 			randNode = Enum.random(nodesPid)
 			a = String.slice((:crypto.hash(:sha256, Kernel.inspect(randNode)) |> Base.encode16),0..7)
 			#it(object,randNode,rootPid,pidHash,nodesPid)
 			initPublish(object,randNode,rootPid,pidHash)
 			#unpublish(a,numNodes,nodesPid)
 			#IO.inspect (getMap(randNode))
 			li = Enum.map((1..numRequests), fn(x) ->
 				request(numNodes,pidHash,rootHash)
 			end)



 			s = Enum.max(li)

 			IO.puts "#{s}"

 		end
 	end


 	def request(numNodes,pidHash,rootHash) do
 		li = Enum.map((1..numNodes), fn(x) ->
 				tsk = Task.async(Tapestry, :routing, [elem(Enum.at(pidHash,x-1),0), elem(Enum.at(pidHash,x-1),1), rootHash,pidHash,1,rootHash])
 				Task.await(tsk)
 			end)
 			 Enum.max(li)
 		end


	 def createNodes(numNodes) do
 		pidHash = Enum.map((1..numNodes), fn(x) ->
 			pid = start_node()
 			pidStr = Kernel.inspect(pid)
 			hashPid = String.slice(:crypto.hash(:sha256, pidStr) |> Base.encode16, 0..7)
 			updateHashState(pid,hashPid)
 			{pid, hashPid}
 		end)
 		pidHash
 	end



 	def createRoutingTable(currNode,pidHash, numNodes, iter, map) do
 		pid = elem(Enum.at(pidHash,iter),0)
 		#GenServer.cast(pid, {:UpdateMapState,pidHash,currNode,numNodes,iter,map})
 		numList = Enum.map((0..9), fn(y) ->
 			tabLoop(1, currNode, pidHash,iter, Integer.to_string(y))

 		end)
 		a = tabLoop(1, currNode, pidHash,iter, "A")
 		b = tabLoop(1, currNode, pidHash,iter, "B")
 		c = tabLoop(1, currNode, pidHash,iter, "C")
 		d = tabLoop(1, currNode, pidHash,iter, "D")
 		e = tabLoop(1, currNode, pidHash,iter, "E")
 		f = tabLoop(1, currNode, pidHash,iter, "F")
 		list = numList ++ [a] ++ [b] ++ [c] ++ [d] ++ [e] ++ [f]
 		map = Map.put(map,iter-1,list)

 		if(iter > 1) do
 			createRoutingTable(currNode,pidHash, numNodes, iter-1, map)

 		else
 			addMap(elem(currNode,0),map)

 		end

 	end


 	def tabLoop(nodeCount, currNode, pidHash,iter, y) when nodeCount > length(pidHash) do
 		nil
 	end


 	def tabLoop(nodeCount, currNode, pidHash,iter, y) when iter == 1 do
 		a = String.at(elem(Enum.at(pidHash,nodeCount-1),1),iter-1)


 		if (String.at(elem(currNode,1),iter-1) == y) do
 			currNode
 		else if(String.at(elem(Enum.at(pidHash,nodeCount-1),1),iter-1) == y) do
 			#IO.inspect (currNode)
 			#IO.puts "#{a}"
 			Enum.at(pidHash,nodeCount-1)
 		else
 			tabLoop(nodeCount+1, currNode, pidHash,iter, y)
 		end
 		end
 	end

 	def tabLoop(nodeCount, currNode, pidHash,iter, y) do
 		if (String.at(elem(currNode,1),iter-1) == y) do
 			currNode
 		else if (String.slice(elem(currNode,1),0..iter-2) == String.slice(elem(Enum.at(pidHash,nodeCount-1),1),0..iter-2) && String.at(		elem(Enum.at(pidHash,nodeCount-1),1),iter-1) == y) do

 			Enum.at(pidHash,nodeCount-1)
 		else
 			tabLoop(nodeCount+1, currNode, pidHash,iter, y)
 		end
 		end
 	end




	def findRoot(object,numNodes,pidHash) do
		objHash = String.slice(:crypto.hash(:sha256, Kernel.inspect(object)) |> Base.encode16, 0..7)
		#IO.puts "Obj #{objHash}"
		nodesHash = Enum.map((1..numNodes), fn(x) ->
			#IO.puts "all #{elem(Enum.at(pidHash,x-1),1)}"
			elem(Enum.at(pidHash,x-1),1)
		end)
 		nodesHash = nodesHash
 		#IO.puts "all #{nodesHash}"
 		root = loop(objHash,nodesHash,numNodes,0)
 		root

 	end

 	def loop(hashID,nodesHash,numNodes,y) when numNodes==1 do
 		Enum.at(nodesHash,0)
 	end


 	def loop(objHash,nodesHash,numNodes,y) when y==7 do
 		selectNodes = Enum.map((1..numNodes), fn(x) ->
 			if(String.slice(objHash,0..y) == String.slice(Enum.at(nodesHash,x-1),0..y)) do

 					Enum.at(nodesHash,x-1)
 			else
 					nil
 			end
		end)
		selectNodes = Enum.filter(selectNodes, fn x -> x != nil end)
		if(length(selectNodes) == 0) do
			str = increment(objHash,y)
			loop(str,nodesHash,numNodes,y)
		end

	end




 	def loop(objHash,nodesHash,numNodes,y) do
 		selectNodes = Enum.map((1..numNodes), fn(x) ->
 			if(String.slice(objHash,0..y) == String.slice(Enum.at(nodesHash,x-1),0..y)) do
 					Enum.at(nodesHash,x-1)
 			else
 					nil
 			end
		end)
		selectNodes = Enum.filter(selectNodes, fn x -> x != nil end)
		if(length(selectNodes) == 0) do
			#ch = Integer.parse(String.at(objHash,y))
			#IO.puts "#{String.at(objHash,y)}"
			str = increment(objHash,y)
			loop(str,nodesHash,numNodes,y)
		else
			loop(objHash,selectNodes,length(selectNodes),y+1)
		end
	end

	def increment(objHash,y) do
		ch = Integer.parse(String.at(objHash,y))

		#IO.puts "#{ch}"
		if(ch != :error) do
			ch = elem(ch,0)
			if(ch == 9) do
				ch = "A"
				str = formString(objHash,ch,y)
				str
			else

				ch = ch + 1
				str = formString(objHash,Integer.to_string(ch),y)
				str
			end
		else
			case String.at(objHash,y) do
			"A" -> str = formString(objHash,"B",y)
			"B" -> str = formString(objHash,"C",y)
			"C" -> str = formString(objHash,"D",y)
			"D" -> str = formString(objHash,"E",y)
			"E" -> str = formString(objHash,"F",y)
			"F" -> str = formString(objHash,"0",y)
			str
			end

		end
	end


	def formString(objHash,ch,y) do
		if(y>0 && y<7) do
			str = String.slice(objHash,0..y-1) <> ch <> String.slice(objHash,y+1..7)
			str
		else if(y == 0) do
			str = ch <> String.slice(objHash,y+1..7)
			str
		else if( y == 7) do
			str = String.slice(objHash,0..y-1) <> ch
			str
		end
		end
		end
	end

	def initPublish(obj,nodePid,rootPid,pidHash) do
		nodeHash = String.slice(:crypto.hash(:sha256, Kernel.inspect(nodePid)) |> Base.encode16, 0..7)
		rootHash = String.slice(:crypto.hash(:sha256, Kernel.inspect(rootPid)) |> Base.encode16, 0..7)
		routing(nodePid,nodeHash,rootHash, pidHash,1,rootHash)

	end

	def routing(firstNode, firstNodeHash, destNodeHash,pidHash,hop,saveNode) do
		updateBp(saveNode,firstNodeHash,pidHash)
		map = getMap(firstNode)
		#IO.puts "1 #{firstNodeHash}"
		#IO.puts "2 #{destNodeHash}"
		#IO.inspect (map)
		nextHop(map,firstNodeHash,destNodeHash,0,pidHash,hop)

	end




	def nextHop(map, currNode, destNode, level, pidHash,hop) do
		dig = String.at(destNode,level)
		if (Integer.parse(dig) != :error) do
			if(Enum.at(Map.get(map,level),elem(Integer.parse(dig),0)) == nil) do
					rand = Enum.random(pidHash)
					routing(elem(rand,0), elem(rand,1),destNode,pidHash,hop,destNode)
			else
				nextNodeHash = elem(Enum.at(Map.get(map,level),elem(Integer.parse(dig),0)),1)
				if(nextNodeHash == destNode) do
					publish(hop)
				else if(nextNodeHash == currNode) do
					#IO.puts "nh #{nextNodeHash}"
					nextHop(map, currNode, destNode, level+1, pidHash,hop)
				else
					#IO.puts "r #{nextNodeHash}"
					nextNode = getPid(nextNodeHash,pidHash)
					#count(n)

					routing(nextNode, nextNodeHash, destNode,pidHash,hop+1,destNode)
				end
				end
			end
		else
			case dig do
					"A" -> nextStep(map,10,destNode,currNode,level,pidHash,hop)
					"B" -> nextStep(map,11,destNode,currNode,level,pidHash,hop)
					"C" -> nextStep(map,12,destNode,currNode,level,pidHash,hop)
					"D" -> nextStep(map,13,destNode,currNode,level,pidHash,hop)
					"E" -> nextStep(map,14,destNode,currNode,level,pidHash,hop)
					"F" -> nextStep(map,15,destNode,currNode,level,pidHash,hop)
			end

		end
	end


	def publish(hop) do
		#IO.puts "#{hop+1}"
		hop
	end

	#def unpublish(node,numNode,nodePid) do
		#Enum.map((1..numNode), fn(x) ->
		#a = List.delete(getList(Enum.at(nodePid,x)),node)
		#changeList(Enum.at(nodePid,x),a)
		#end)

	#end




	def nextStep(map,pos,destNode,currNode,level,pidHash,hop) do
		if(Enum.at(Map.get(map,level),pos) == nil) do
			rand = Enum.random(pidHash)
			routing(elem(rand,0), elem(rand,1),destNode,pidHash,hop,destNode)
		else
			nextNodeHash = elem(Enum.at(Map.get(map,level),pos),1)
			if(nextNodeHash == currNode) do
				nextHop(map, currNode, destNode, level+1, pidHash,hop)
			else
				nextNode = getPid(nextNodeHash,pidHash)
				routing(nextNode, nextNodeHash, destNode,pidHash,hop+1,destNode)
			end
		end
	end

	def updateBp(destNode,currNode,pidHash) do
		destPid = getPid(destNode,pidHash)
		currPid = getPid(currNode,pidHash)
		GenServer.call(currPid, {:UpdateBpState,destPid})

	end


	def handle_call({:UpdateBpState, destPid}, _from, state) do

		{a,b,c,d} = state
		val = Enum.find(d, fn x -> x == destPid end)
		if(val != nil) do
    		state = {a,b,c,d ++ [destPid]}
    	end
    	{:reply,destPid,state}
    end

	def getPid(hashVal,pidHash) do
		numNodes = length(pidHash)
		#IO.inspect (hashVal)
		nodesHash = Enum.map((1..numNodes), fn(x) ->

				elem(Enum.at(pidHash, (x-1)),1)
		end)
		ind = Enum.find_index(nodesHash, fn(x) -> x == hashVal end)
		#IO.puts "#{ind}"
		elem(Enum.at(pidHash,ind),0)
 	end


	def start_node() do
        {:ok,pid}=GenServer.start_link(__MODULE__, :ok,[])
        pid
    end

    def init(:ok) do
        {:ok, {" ", " ", Map.new(), []}}
    end

    def addMap(pid,map) do
    	GenServer.cast(pid, {:UpdateMapState,map})
    end

    def changeList(pid,list) do
    	GenServer.cast(pid, {:changeBpState,list})
    end

    def handle_cast({:changeBpState,list},state) do

    	{a,b,c,d} = state
    	state = {a,b,c,list}
    	{:noreply,state}
    end

    def getList(pid) do
    	GenServer.call(pid, {:GetBpState})
    end



    def handle_call({:GetBpState}, _from, state) do
    	{_,_,_,d} = state
    	{:reply,d,state}
    end


    def updateHashState(pid,hashPid) do
 		GenServer.cast(pid, {:UpdateHashState,hashPid})
    end

    def getMap(pid) do
    	GenServer.call(pid, {:GetMapState})
    end

    def handle_call({:GetMapState}, _from, state) do
    	{_,_,c,_} = state
    	{:reply,c,state}
    end

    def getHashVal(pid) do
    	GenServer.call(pid, {:GetHashVal})
    end


    def handle_call({:GetHashVal}, _from, state) do
    	{a,_,_,_} = state
    	{:reply,a,state}
    end

    def handle_cast({:UpdateMapState,map},state) do

    	{a,b,c,d} = state
    	state = {a,b,map,d}
    	{:noreply,state}
    end


    def handle_cast({:UpdateHashState, hashPid}, state) do
    	{a,b,c,d} = state
    	state = {hashPid,b,c,d}
    	{:noreply,state}
    end

end
