exampleGraph = {
    0 : [(1, 10), (2, 20)],
    1 : [(3,50), (4,10)],
    2 : [(3,20),(4,33)],
    3 : [(4,20),(5,2)],
    4 : [(5,1)],
    5 : []
}

def dijkstra(origin: int, destination: int,  graph: {}) -> tuple[int, list]:
    #final cost and path
    path = []               #path from origin to destination
    index = destination
    nodes = {}              #
    costs = []              #list of costs to each node from start
    previousNodes = []      #list of previous nodes

    #initialize costs and path
    for item in range(len(graph)):
        costs.append(float('inf'))
        previousNodes.append(-1)
        nodes.update({item : float('inf')})

    costs[origin] = 0
    nodes.update({origin: 0})

    #find the shortest path
    while nodes:
        minimum = min(nodes,key=nodes.get)
        del nodes[minimum]

        for neighbor in graph[minimum]:
            if neighbor[0] not in nodes:
                continue
            else:
                #relaxation - if known path from origin to neighbor of current node is longer path to current node + edge -> substitution
                if costs[neighbor[0]] > (costs[minimum] + graph[minimum][graph[minimum].index(neighbor)][1]):
                    costs[neighbor[0]] = costs[minimum] + graph[minimum][graph[minimum].index(neighbor)][1]
                    nodes.update({neighbor[0]:costs[neighbor[0]]})
                    previousNodes[neighbor[0]] = minimum

    #generate the shortest path
    while index!=origin:
        path.append(index)
        index = previousNodes[index]
    path.append(origin)

    path = path[::-1]
    return costs[destination], path

if __name__ == '__main__':
    print(dijkstra(0,4, exampleGraph))