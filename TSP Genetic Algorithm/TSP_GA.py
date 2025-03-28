import numpy as np
import random

#example data:
CITIES = np.array([
[0, 0], [1, 5], [5, 2], [6, 6], [8, 3]
])

#algorithm default parameters
POPULATION_SIZE = 10
NUMBER_OF_GENERATIONS = 1000
MUTATION_CHANCE = 0.05

example_route = np.array([1,3,4,2,0,1])

#generate initial TSP population of given size (pop_size)
def generate_population(cities, pop_size):
    length = int(((cities.size)/2)+1)
    population =  np.array([np.random.permutation(length-1) for _ in range(pop_size)])
    return np.array([np.append(route, route[0]) for route in population])
    
#calculate distance between chosen cities
def euclidean_distance(city1, city2):
    return np.sqrt(np.sum((city1 - city2) ** 2))

#calculate route length
def total_route_distance(route, cities):
    distance = 0
    for i in range(len(route) - 1):
        city_a = cities[route[i]]
        city_b = cities[route[i + 1]]
        distance += euclidean_distance(city_a, city_b)
    return distance

#selection
#def selection(population):

#crossover - to make a child for two routes
def crossover(route1, route2):
    route1 = route1[:-1]
    route2 = route2[:-1]
    length = route1.size
    subsection_length = random.randrange(1,length,1)
    subsection_start = random.randrange(0,length-subsection_length+1,1)
    subsection1 = route1[subsection_start:subsection_start+subsection_length]
    child = np.zeros(length)
    child[subsection_start:subsection_start+subsection_length] = subsection1

    child_index = 0

    for i in range(length):
        if not route2[i] in child:
            while child[child_index] != 0:
                child_index = child_index+1
            child[child_index] = route2[i]
        
    child = np.append(child, child[0])
    print(subsection1, child)

#mutation of a route by swapping values
def mutate(route):
    route = route[:-1]
    rand1 = random.randrange(0,route.size)
    while (True):
        rand2 = random.randrange(0,route.size)
        if rand1 != rand2:
            break

    #swap values
    tmp = route[rand1]
    route[rand1] = route[rand2]
    route[rand2] = tmp

    route = np.append(route, route[0])
    return route


#final algorithm
#def TSP_genetic_algorithm(arr: np.array):


if __name__ == '__main__':
    #pop = generate_population(CITIES, POPULATION_SIZE)
    #print(pop, pop[0])
    #crossover(np.array([0,1,2,3,4,5,6,7,8,9,0]), np.array([9,8,7,6,5,4,3,2,1,0,9]))
    print(mutate(np.array([0,1,2,3,0])))