# from memory, I am trying to draw out the old LA ECS env
from diagrams import Cluster, Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import ELB
from diagrams.aws.compute import ElasticContainerServiceContainer

with Diagram("old ECS layout", show=False, direction="TB"):
    ELB("elb") >> [ElasticContainerServiceContainer("Container 1"),
                    ElasticContainerServiceContainer("Container 2"),
                    ElasticContainerServiceContainer("Container 3"),
                    ElasticContainerServiceContainer("Container 4"),
                    ElasticContainerServiceContainer("Container 5")] >> RDS("events db")