Create a VM and open the below firewalls at VM level using the block dynamic. 

80 - IP Range Specific

8080 - IP Range Specific

443 - IP Range Specific

9000 - IP Range Specific

2028 - IP Range Specific

9090 - IP Range Specific

22 - IP Range Specific

3306 - IP Range Specific

5432 - IP Range Specific

422 - IP Range Specific

**ANSWER: Introduce a variable of type map(any). Loop the values of this variable inside dynamic { ... }**